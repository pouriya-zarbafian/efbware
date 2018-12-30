//
//  XmlUtils.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 25/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class XmlUtils: NSObject {

    private static let LOGGER = Logger.getInstance()
    
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
    
    static func parseSearchResult(xml: String) -> Array<DocumentData> {
        
        let nsdata = xml.data(using: .utf8)
    
        var doc: AEXMLDocument
        
        var documents = Array<DocumentData>()
        
        do {
            try doc = AEXMLDocument(xml: nsdata!)
            
            if doc["response"]["items"]["item"].count > 0 {
                // parse known structure
                for item in doc["response"]["items"]["item"].all! {
                    
                    let docLabel = item["label"].string
                    let docId = item["id"].string
                    let fileName = item["fileName"].string
                    let fileRef = item["files"]["file"]["fileRef"].string
                    let totalPart = item["files"]["file"]["totalPart"].string
                    
                    let documentData = DocumentData(label: docLabel, fileName: fileName, docId: docId, fileRef: fileRef, parts: Int(totalPart)!)
                    
                    LOGGER.trace(msg: "parsed document, label=\(documentData.label), docId=\(documentData.docId), fileRef=\(documentData.fileRef), totalPart=\(documentData.parts)")
                    
                    documents.append(documentData)
                }
            }
        }
        catch let error as NSError {
            print("Error while parsing xml\n\(xml)\nerror=\(error.localizedDescription)")
        }
        
        return documents
    }
}
