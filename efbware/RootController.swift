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
    
    static var loggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

