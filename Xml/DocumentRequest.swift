//
//  DocumentRequest.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 25/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentRequest: NSObject {

    func toXml() -> String {
        
        let xmlDoc = AEXMLDocument()
        let req = xmlDoc.addChild(name: "request")
        
        XmlUtils.addContext(req: req, pageNumber: 1, pageSize: 10, viewRestricted: false)
        
        let nature = AEXMLElement(name: "nature", value: "ALL_ITEMS")
        let category = AEXMLElement(name: "category", value: "MANUAL")
        let categories = AEXMLElement(name: "categories")
        categories.addChild(category)
        
        let query = req.addChild(name: "query")
        query.addChild(nature)
        query.addChild(categories)
        
        return xmlDoc.xml
    }
}
