//
//  ViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class RootController: UITabBarController {

    private let LOGGER = Logger.getInstance()
    
    //var advanceTasksTImer: Timer
    
    static var loggedIn = false
    
    let runAdvanceTasks: (Timer) -> Void = {
        
        if(loggedIn) {
            print("searching for new documents, timer=\($0.fireDate), interval=\($0.timeInterval)")
            
            var newDocs = DatabaseService.getInstance().listNewDocuments()
            print("found \(newDocs.count) documents with state \(DocumentStatus.NEW)")
            
            let docService = DocumentService()
            
            for doc in newDocs {
                docService.handle(document: doc)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Init DB
        _ = DatabaseService.getInstance()
        
        //advanceTasksTImer =
        Timer.scheduledTimer(withTimeInterval: Constants.ACTIVITY_ADVANCE_TASKS_PERIOD, repeats: true, block: runAdvanceTasks)
        
        LOGGER.info(msg: "💜 Timer started")
    }

    override func viewDidAppear(_ animated: Bool) {
        // check login
        if RootController.loggedIn {
            LOGGER.info(msg: "user is logged in")
        }
        else {
            LOGGER.info(msg: "user is not logged in, show login dialog")
            self.performSegue(withIdentifier: Constants.SEGUE_APP_TO_LOGIN, sender: nil)
        }
    }
}

