//
//  DocumentsViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentsViewController: UIViewController {

    private let LOGGER = Logger.getInstance()
    
    //private var dokaService: DokaService
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOGGER.debug(msg: "DocumentsViewController.viewDidLoad")
        
        let dokaService = DokaService(sid: LoginController.sid)
        
        dokaService.getDocuments()
    }
}
