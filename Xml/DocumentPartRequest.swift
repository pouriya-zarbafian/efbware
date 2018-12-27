//
//  DocumentPartRequest.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentPartRequest: NSObject {

    let document: DocumentData
    let part: DocumentPartData
    
    init(document: DocumentData, part: DocumentPartData) {
        self.document = document
        self.part = part
    }
    
    func toXml() -> String {
        
        let xmlDoc = AEXMLDocument()
        let req = xmlDoc.addChild(name: "request")
        
        //XmlUtils.addContext(req: req, pageNumber: 1, pageSize: 10, viewRestricted: false)
        
        let docId = AEXMLElement(name: "documentId", value: String(document.docId))
        req.addChild(docId)
        
        let fileRef = AEXMLElement(name: "fileRef", value: document.fileRef)
        req.addChild(fileRef)
        
        let partNum = AEXMLElement(name: "partNum", value: String(part.partNumber))
        req.addChild(partNum)
        
        return xmlDoc.xml
    }
}
