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
    
    private let databaseService = DatabaseFacade.getInstance()
    
    private let fileSystemService = FileSystemService.getInstance()
    
    private var targetDocumentUrl: URL!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: DocumentTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! DocumentTableViewCell
        
        let curDoc = self.documents[indexPath.row]
        cell.labelCell?.text = curDoc.label
        
        
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
            let docUrl = fileSystemService.getDocumentUrl(document: targetDoc)
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
            
            self.LOGGER.trace(msg: "DocumentsViewController.onResults, size=\($0.count)")
            
            // list of docs from server
            let serverDocs: [DocumentData] = $0
            
            // list of docs in database
            let dbList = self.databaseService.listAllDocuments()
            
            // compare
            let newDocs = self.findNewDocuments(sourceList: serverDocs, targetList: dbList)
            
            // add new docs
            for newDoc in newDocs {
                newDoc.status = DocumentStatus.NEW
                
                self.LOGGER.info(msg: "New document from server: \(newDoc.label)")
                
                do {
                    
                    if let deletedDoc = self.databaseService.findDeletedDocumentByDocument(docId: newDoc.docId) {
                        if let resetDoc = self.databaseService.resetDocument(document: deletedDoc) {
                            self.documents.append(resetDoc)
                        }
                        else {
                            self.LOGGER.error(msg: "Error reseting document in database: docId=\(deletedDoc.docId), label=\(deletedDoc.label)")
                        }
                    } else {
                        let insertedDoc = try self.databaseService.insertDocument(document: newDoc)
                        self.documents.append(insertedDoc)
                    }
                    
                } catch {
                    self.LOGGER.error(msg: "Error inserting document in database: \(error.localizedDescription)")
                }
            }
            
            // check for deleted docs, just reversing the arguments
            let delDocs = self.findNewDocuments(sourceList: dbList, targetList: serverDocs)
            
            // add new docs
            for delDoc in delDocs {
                
                self.LOGGER.info(msg: "Deleting document: \(delDoc.label)")
                
                do {
                    // TODO: do these inside a transaction
                    self.databaseService.deleteDocumentPartByDocument(document: delDoc)
                    self.databaseService.deleteDocument(document: delDoc)
                    
                    // remove from local list
                    let haveSameId: (DocumentData) throws -> Bool = {
                        return $0.docId == delDoc.docId
                    }
                    
                    if let indexToDelete = try self.documents.firstIndex(where: haveSameId) {
                        self.documents.remove(at: indexToDelete)
                    } else {
                        self.LOGGER.error(msg: "Document not found for removal: \(delDoc.docId)")
                    }
                }
                catch {
                    self.LOGGER.error(msg: "Error deleting document, id=\(delDoc.docId), label=\(delDoc.label)")
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
    private func findNewDocuments(sourceList: Array<DocumentData>, targetList: Array<DocumentData>) -> Array<DocumentData> {
        
        var newDocs: Array<DocumentData> = []
        
        var localDic: [String:DocumentData] = [:]
        
        for doc in targetList {
            let key = KeyUtils.buildDocumentKey(doc: doc)
            localDic[key] = doc
        }
        
        for doc in sourceList {
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
    
    /**
     * Compare and check which douments are deleted.
     *//*
    private func findDeletedDocuments(serverList: Array<DocumentData>, dbList: Array<DocumentData>) -> Array<DocumentData> {
        
        var delDocs: Array<DocumentData> = []
        
        var serverDic: [String:DocumentData] = [:]
        
        for doc in serverList {
            let key = KeyUtils.buildDocumentKey(doc: doc)
            serverDic[key] = doc
        }
        
        for doc in dbList {
            let key = KeyUtils.buildDocumentKey(doc: doc)
            if (serverDic[key] != nil) {
                // TODO: handle updates on synchronized document
            }
            else {
                delDocs.append(doc)
            }
        }
        
        return delDocs
    }
    */
}
