//
//  DocumentService.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 26/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentService: NSObject {

    private let LOGGER = Logger.getInstance()
    
    func handle(document: DocumentData) {
        
        LOGGER.debug(msg: "handle, id=\(document.id)")
        
        let doc = DatabaseService.getInstance().findDocumentById(id: document.id)
        
        if doc == nil {
            LOGGER.debug(msg: "document not found, id=\(document.id)")
        }
        else {
            LOGGER.debug(msg: "document found, id=\(document.id)")
            
            for partNumber in 0..<document.parts {
                let part = DocumentPartData(partNumber: partNumber, documentId: document.id)
                _ = DatabaseService.getInstance().insertDocumentPart(part: part)
            }
            
            doc!.status = DocumentStatus.BUILDING
            
            _ = DatabaseService.getInstance().updateDocument(document: doc!)
        }
    }
}
