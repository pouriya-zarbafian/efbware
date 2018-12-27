//
//  DocumentPartDao.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation
import SQLite3

class DocumentPartDao: NSObject {

    private let LOGGER = Logger.getInstance()
    
    private let dbFileUrl: URL
    
    init(databaseFileUrl: URL) {
        self.dbFileUrl = databaseFileUrl
        LOGGER.info(msg: "dbFileUrl=\(dbFileUrl)")
        super.init()
    }
    
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
    
    /**
     * Insert a document part in the local database
     */
    func create(part: DocumentPartData) throws -> DocumentPartData {
        
        // open database
        var db: OpaquePointer?
        if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
            LOGGER.error(msg: "Error opening database")
            throw DatabaseError.connectionError(message: "Cannot open database")
        }
        else {
            LOGGER.debug(msg: "Database connection successful")
        }
        
        // insert data
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "insert into document_part (part_number, document, status) values (?, ?, ?)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error preparing insert: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error prepare: \(errmsg)")
        }
        
        // insert
        // bind partNumber
        if sqlite3_bind_int64(statement, 1, sqlite3_int64(part.partNumber)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding partNumber: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind document
        if sqlite3_bind_int64(statement, 2, sqlite3_int64(part.documentId)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding document: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind status
        if sqlite3_bind_text(statement, 3, part.status, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding status: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error while inserting document part: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error while inserting document part: \(errmsg)")
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            LOGGER.error(msg: "Error closing database")
        }
        
        db = nil
        
        LOGGER.info(msg: "Document part inserted, id=\(part.id), label=\(part.partNumber), docId=\(part.documentId), status=\(part.status)")
        
        return part
    }
    
    /**
     * Update a document
     */
    func update(part: DocumentPartData) throws -> DocumentPartData {
        
        // open database
        var db: OpaquePointer?
        if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
            LOGGER.error(msg: "Error opening database")
            throw DatabaseError.connectionError(message: "Cannot open database")
        }
        else {
            LOGGER.debug(msg: "Database connection successful")
        }
        
        // update data
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "UPDATE document_part SET status = ? WHERE id = ?", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error preparing insert: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error prepare: \(errmsg)")
        }
        
        // update
        // bind status
        if sqlite3_bind_text(statement, 1, part.status, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding status: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind document id
        if sqlite3_bind_int64(statement, 2, sqlite3_int64(part.id)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding doc id: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error while updating document: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error while updating document: \(errmsg)")
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            LOGGER.error(msg: "error closing database")
        }
        
        db = nil
        
        LOGGER.info(msg: "Document part updated, id=\(part.id), status=\(part.status)")
        
        return part
    }
    
    /**
     * List new document parts in the local database
     */
    func listPartsByStatus(document: Int, status: String) throws -> Array<DocumentPartData> {
        
        var parts: Array<DocumentPartData> = []
        
        // open database
        var db: OpaquePointer?
        if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
            LOGGER.error(msg: "Error opening database")
            throw DatabaseError.connectionError(message: "Cannot open database connection")
        }
        else {
            LOGGER.debug(msg: "Database connection successful")
        }
        
        // sql
        let sql = "SELECT id, part_number, document, status from document_part WHERE document = " + String(document) + " AND status = '" + status + "'"
        
        
        // query
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error preparing select: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error preparing select: \(errmsg)")
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
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
            } else {
                LOGGER.debug(msg: "statusValue not found")
            }
            
            // add to list
            let part = DocumentPartData(id: idValue, partNumber: partNumberValue, documentId: docIdValue, status: statusValue)
            
            parts.append(part)
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            LOGGER.error(msg: "Error closing database")
        }
        
        db = nil
        
        return parts
    }
}
