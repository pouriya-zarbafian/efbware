//
//  DocumentsViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let LOGGER = Logger.getInstance()
    
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
        }
    }
    
    private var documents = [DocumentData]()
    
    //private var dokaService: DokaService
    
    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOGGER.debug(msg: "DocumentsViewController.viewDidLoad")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
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
    
    func findNewDocuments(serverList: Array<DocumentData>, dbList: Array<DocumentData>) -> Array<DocumentData> {
        
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
