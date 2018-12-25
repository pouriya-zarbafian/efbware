//
//  XmlUtils.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 25/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class XmlUtils: NSObject {

    static func addContext(req: AEXMLElement) {
        
        let language = AEXMLElement(name: "language", value: "ENG")
        let timeZone = AEXMLElement(name: "timeZone", value: "UTC")
        
        let context = req.addChild(name: "context")
        context.addChild(language)
        context.addChild(timeZone)
    }
    static func addContext(req: AEXMLElement, pageNumber: Int, pageSize: Int, viewRestricted: Bool) {
        
        let language = AEXMLElement(name: "language", value: "ENG")
        let timeZone = AEXMLElement(name: "timeZone", value: "UTC")
        let pageNumberXml = AEXMLElement(name: "pageNumber", value: String(pageNumber))
        let pageSizeXml = AEXMLElement(name: "pageSize", value: String(pageSize))
        let viewRestrictedXml = AEXMLElement(name: "viewRestricted", value: String(viewRestricted))
        
        let context = req.addChild(name: "context")
        context.addChild(language)
        context.addChild(timeZone)
        context.addChild(pageNumberXml)
        context.addChild(pageSizeXml)
        context.addChild(viewRestrictedXml)
    }
}
