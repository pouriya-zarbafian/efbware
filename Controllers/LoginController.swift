//
//  LoginController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    private let LOGGER = Logger.getInstance()
    
    @IBAction func loginButton(_ sender: UIButton) {
        LOGGER.info(msg: "loginButton")
        RootController.loggedIn = true
        self.dismiss(animated: false, completion: nil)
    }
}
