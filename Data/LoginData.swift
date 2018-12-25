//
//  LoginData.swift
//  demoefb
//
//  Created by Pouriya Zarbafian on 23/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class LoginData {
    
    var customerName: String
    var user: String
    var password: String
    
    init(customerName: String, user: String, password: String) {
        self.customerName = customerName
        self.user = user
        self.password = password
    }
}
