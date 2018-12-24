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
        //let header = xml.addChild(name: "header")
        //header.addChild(name: "type", value: "mrtd-result")
        //let body = xml.addChild(name: "payload")
        
        let language = AEXMLElement(name: "language", value: "ENG")
        let timeZone = AEXMLElement(name: "timeZone", value: "UTC")
        
        let context = req.addChild(name: "context")
        context.addChild(language)
        context.addChild(timeZone)
        
        req.addChild(name: "customerName", value: loginData.customerName)
        req.addChild(name: "user", value: loginData.user)
        req.addChild(name: "password", value: loginData.password)
        
        return xmlDoc.xml
    }
}
