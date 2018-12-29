//
//  DocumentsViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit
import PDFKit

class DocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let LOGGER = Logger.getInstance()
    
    private let databaseService = DatabaseService.getInstance()
    
    private var targetDocumentUrl: URL!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let cell: DocumentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DocumentTableViewCell
        
        //cell.textLabel?.text = self.documents[indexPath.row].label + " - " + self.documents[indexPath.row].status
        
        let curDoc = self.documents[indexPath.row]
        cell.labelCell?.text = curDoc.label + "- CUSTOM - " + curDoc.status
        
        
        var loadingImage: UIImage!
        
        switch curDoc.status {
        case DocumentStatus.NEW:
            loadingImage = UIImage(named: "empty")
        case DocumentStatus.BUILDING:
            loadingImage = UIImage.gifImageWithName("loading")
        case DocumentStatus.COMPLETE:
            loadingImage = UIImage(named: "ready")
        default:
            loadingImage = UIImage(named: "error")
        }

        cell.iconCell.image = loadingImage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LOGGER.debug(msg: "You selected cell #\(indexPath.row)")
        if let cell = tableView.cellForRow(at: indexPath) {
            
            LOGGER.debug(msg: "label=\(String(describing: cell.textLabel))")
            
            let targetDoc = documents[indexPath.row]
            let docUrl = FileSystemService.getInstance().getDocumentsUrl().appendingPathComponent(targetDoc.fileName)
            LOGGER.debug(msg: "tagerUrl=\(docUrl.path)")
            
            let viewController = self.parent as! RootController
            
            viewController.showDocumentViewer(documentUrl: docUrl)

        }
    }
    
    private var documents = [DocumentData]()
    
    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOGGER.debug(msg: "DocumentsViewController.viewDidLoad")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshDocumentsFromDb()
        
        let checkForDocs: (Timer) -> Void = {
            
            self.LOGGER.debug(msg: "Timer running getDocumentsFromServer")
            _ = $0
            
            self.refreshDocumentsFromDb()
            self.checkDocumentsFromServer()
        }
        
        Timer.scheduledTimer(withTimeInterval: Constants.ACTIVITY_CHECK_FOR_DOCUMENTS_PERIOD, repeats: true, block: checkForDocs)
        
        LOGGER.info(msg: "💜 DocumentsViewController: timer started")

    }
    
    private func refreshDocumentsFromDb() {
        
        let dbDocs = getDocumentsFromDb()
        
        documents.removeAll()
        
        for dbDoc in dbDocs {
            self.documents.append(dbDoc)
        }
    }
    
    private func getDocumentsFromDb() -> [DocumentData] {
        
        return databaseService.listAllDocuments()
    }
    
    private func checkDocumentsFromServer() {
     
        let dokaService = DokaService(sid: LoginController.sid)
        
        let onResult: (Array<DocumentData>) -> Void = {
            
            self.LOGGER.info(msg: "DocumentsViewController.onResults, size=\($0.count)")
            
            // list of docs from server
            let serverDocs: [DocumentData] = $0
            
            // list of docs in database
            let dbList = self.databaseService.listAllDocuments()
            
            // compare
            let newDocs = self.findNewDocuments(serverList: serverDocs, dbList: dbList)
            
            // add new docs
            for newDoc in newDocs {
                newDoc.status = DocumentStatus.NEW
                
                self.LOGGER.info(msg: "New document from server: \(newDoc.label)")
                
                do {
                    let insertedDoc = try self.databaseService.insertDocument(document: newDoc)
                    self.documents.append(insertedDoc)
                } catch {
                    self.LOGGER.error(msg: "Error inserting document in database: \(error.localizedDescription)")
                }
            }
            
            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
        
        dokaService.getDocuments(onResult: onResult)
    }
    
    /**
     * Compare and check which douments are new.
     */
    private func findNewDocuments(serverList: Array<DocumentData>, dbList: Array<DocumentData>) -> Array<DocumentData> {
        
        var newDocs: Array<DocumentData> = []
        
        var localDic: [String:DocumentData] = [:]
        
        for doc in dbList {
            let key = KeyUtils.buildDocumentKey(doc: doc)
            localDic[key] = doc
        }
        
        for doc in serverList {
            let key = KeyUtils.buildDocumentKey(doc: doc)
            if (localDic[key] != nil) {
                // TODO: handle updates on synchronized document
            }
            else {
                newDocs.append(doc)
            }
        }
        
        return newDocs
    }
    
}
