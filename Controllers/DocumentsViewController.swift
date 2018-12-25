//
//  DocumentsViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.documents.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")!
        
        cell.textLabel?.text = self.documents[indexPath.row].label
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        LOGGER.debug(msg: "You selected cell #\(indexPath.row)!")
    }
    
    private let LOGGER = Logger.getInstance()
    
    private var documents = [DocumentData]()
    
    //private var dokaService: DokaService
    
    // MARK: UI
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOGGER.debug(msg: "DocumentsViewController.viewDidLoad")
        
        // TODO
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.dataSource = self
        tableView.delegate = self
        
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
