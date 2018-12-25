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
            
            self.LOGGER.error(msg: "DocumentsViewController.onResults, size=\($0.count)")
            
            self.documents.removeAll()
            
            for documentData in $0 {
                self.documents.append(documentData)
                
                self.LOGGER.info(msg: "added document, label=\(documentData.label), docId=\(documentData.docId), fileRef=\(documentData.fileRef), totalPart=\(documentData.parts)")
            }
            
            self.LOGGER.debug(msg: "documents.count=\(self.documents.count)")

            DispatchQueue.main.async{
                self.tableView.reloadData()
            }
        }
 
        dokaService.getDocuments(onResult: onResult)
    }
}
