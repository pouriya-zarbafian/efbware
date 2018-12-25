//
//  DocumentData.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 25/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentData: NSObject {

    var label: String
    var docId: String
    var fileRef: String
    var parts: Int
    
    init(label: String, docId: String, fileRef: String, parts: Int) {
        self.label = label
        self.docId = docId
        self.fileRef = fileRef
        self.parts = parts
    }
    
}
