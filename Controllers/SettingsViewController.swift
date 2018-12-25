//
//  SettingsViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    private let LOGGER = Logger.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOGGER.debug(msg: "SettingsViewController.viewDidLoad")
    }
}
