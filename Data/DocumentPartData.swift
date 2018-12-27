//
//  DocumentPart.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentPartData: NSObject {

    var id: Int
    var partNumber: Int
    var documentId: Int
    var status: String
    
    init(partNumber: Int, documentId: Int) {
        self.id = Constants.ID_UNDEFINED
        self.partNumber = partNumber
        self.documentId = documentId
        self.status = DocumentPartStatus.NEW
    }
    
    init(id: Int, partNumber: Int, documentId: Int, status: String) {
        self.id = id
        self.partNumber = partNumber
        self.documentId = documentId
        self.status = status
    }
}
