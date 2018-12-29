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
    
    private var targetDocumentUrl: URL!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.textLabel?.text = self.documents[indexPath.row].label
        
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
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        getDocumentsFromServer()
        
        let checkForDocs: (Timer) -> Void = {
            self.LOGGER.debug(msg: "Timer running getDocumentsFromServer")
            _ = $0
            self.getDocumentsFromServer()
        }
        
        Timer.scheduledTimer(withTimeInterval: Constants.ACTIVITY_CHECK_FOR_DOCUMENTS_PERIOD, repeats: true, block: checkForDocs)
        
        LOGGER.info(msg: "💜 DocumentsViewController: timer started")

    }
    
    private func getDocumentsFromServer() {
     
        let dokaService = DokaService(sid: LoginController.sid)
        
        let onResult: (Array<DocumentData>) -> Void = {
            
            self.LOGGER.info(msg: "DocumentsViewController.onResults, size=\($0.count)")
            
            self.documents.removeAll()
            
            // list of docs from server
            for documentData in $0 {
                self.documents.append(documentData)
                
                self.LOGGER.info(msg: "added document, label=\(documentData.label), docId=\(documentData.docId), fileRef=\(documentData.fileRef), totalPart=\(documentData.parts)")
                
            }
            
            self.LOGGER.debug(msg: "server documents.count=\(self.documents.count)")
            
            // list of docs in database
            let dbList = DatabaseService.getInstance().listAllDocuments()
            
            // compare
            let newDocs = self.findNewDocuments(serverList: self.documents, dbList: dbList)
            
            // add new docs
            for newDoc in newDocs {
                newDoc.status = DocumentStatus.NEW
                // TODO
                _ = DatabaseService.getInstance().insertDocument(document: newDoc)
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
                LOGGER.debug(msg: "key existed: \(key)")
            }
            else {
                LOGGER.debug(msg: "new key: \(key)")
                newDocs.append(doc)
            }
        }
        
        return newDocs
    }
    
}
