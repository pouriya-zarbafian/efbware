//
//  SelectDocumentPart.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 28/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation
import SQLite3

class SelectDocumentPart: NSObject {

    static var sql = "SELECT id, part_number, document, status from document_part"
    
    static func getSql() -> String {
        return sql
    }
    
    static func getSqlWhereId() -> String {
        return sql + " WHERE id = :id"
    }
    
    static func getSqlWhereStatus() -> String {
        return sql + " WHERE status = :status"
    }
    
    static func getParams(id: Int) -> [String: Any] {
        
        let params: [String: Any] = ["id": id]
        
        return params
    }
    
    static func getParams(status: String) -> [String: Any] {
        
        let params: [String: Any] = ["status": status]
        
        return params
    }
    
    static let DocumentPartRowMapper: (_ :OpaquePointer) -> DocumentPartData = {
        
        let statement = $0
        
        // id
        let id = sqlite3_column_int64(statement, 0)
        let idValue = Int(id)
        
        // parts
        let partNumber = sqlite3_column_int64(statement, 1)
        let partNumberValue = Int(partNumber)
        
        // parts
        let docId = sqlite3_column_int64(statement, 2)
        let docIdValue = Int(docId)
        
        // status
        var statusValue = ""
        if let cString = sqlite3_column_text(statement, 3) {
            statusValue = String(cString: cString)
        }
        
        return DocumentPartData(id: idValue, partNumber: partNumberValue, documentId: docIdValue, status: statusValue)
    }
}
