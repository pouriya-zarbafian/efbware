//
//  KeyUtils.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class KeyUtils: NSObject {

    static func buildDocumentKey(doc: DocumentData) -> String {
        
        let key = doc.docId + "_" + doc.fileRef
        return key
    }
    static func buildDocumentPartKey(doc: DocumentData, part: DocumentPartData) -> String {
        
        let key = buildDocumentKey(doc: doc) + "_" + String(part.partNumber)
        return key
    }
}
