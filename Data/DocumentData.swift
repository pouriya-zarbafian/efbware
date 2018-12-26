//
//  DocumentData.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 25/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentData: NSObject {

    var id: Int
    var label: String
    var fileName: String
    var docId: String
    var fileRef: String
    var parts: Int
    var status: String
    
    init(label: String, fileName: String, docId: String, fileRef: String, parts: Int) {
        self.id = Constants.ID_UNDEFINED
        self.label = label
        self.fileName = fileName
        self.docId = docId
        self.fileRef = fileRef
        self.parts = parts
        self.status = DocumentStatus.NONE
    }
    
    init(id: Int, label: String, fileName: String, docId: String, fileRef: String, parts: Int, status: String) {
        self.id = id
        self.label = label
        self.fileName = fileName
        self.docId = docId
        self.fileRef = fileRef
        self.parts = parts
        self.status = status
    }
}
