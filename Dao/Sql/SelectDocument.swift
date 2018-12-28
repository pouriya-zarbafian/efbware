//
//  SelectDocument.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 28/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation
import SQLite3

class SelectDocument: NSObject {

    static var sql = "SELECT id, label, file_name, doc_id, file_ref, parts, status FROM document"
    
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
    
    static func getReturnTypes() -> Array<SqlType> {
        
        var types: Array<SqlType> = []
        types.append(.long)
        types.append(.string)
        types.append(.string)
        types.append(.string)
        types.append(.string)
        types.append(.long)
        types.append(.string)
        
        return types
    }
    
    static let DocumentRowMapper: (_ :OpaquePointer) -> DocumentData = {
        
        let statement = $0
        
        // id
        let id = sqlite3_column_int64(statement, 0)
        let idValue = Int(id)
        
        // label
        var labelValue = ""
        if let cString = sqlite3_column_text(statement, 1) {
            labelValue = String(cString: cString)
        }
        
        // fileName
        var fileNameValue = ""
        if let cString = sqlite3_column_text(statement, 2) {
            fileNameValue = String(cString: cString)
        }
        
        // doc id
        var docValue = ""
        if let cString = sqlite3_column_text(statement, 3) {
            docValue = String(cString: cString)
        }
        
        // fileref
        var fileValue = ""
        if let cString = sqlite3_column_text(statement, 4) {
            fileValue = String(cString: cString)
        }
        
        // parts
        let parts = sqlite3_column_int64(statement, 5)
        let partsValue = Int(parts)
        
        // status
        var statusValue = ""
        if let cString = sqlite3_column_text(statement, 6) {
            statusValue = String(cString: cString)
        }
        
        return DocumentData(id: idValue, label: labelValue, fileName: fileNameValue, docId: docValue, fileRef: fileValue, parts: partsValue, status: statusValue)
    }
}
