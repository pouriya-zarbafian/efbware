//
//  LoginRequest.swift
//  demoefb
//
//  Created by Pouriya Zarbafian on 23/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation

class LoginRequest {

    static func toXml(loginData: LoginData) -> String {
        
        let xmlDoc = AEXMLDocument()
        let req = xmlDoc.addChild(name: "request")
        
        XmlUtils.addContext(req: req)
        
        req.addChild(name: "customerName", value: loginData.customerName)
        req.addChild(name: "user", value: loginData.user)
        req.addChild(name: "password", value: loginData.password)
        
        return xmlDoc.xml
    }
}
