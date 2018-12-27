//
//  DocumentDao.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 26/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//
import Foundation
import SQLite3

class DocumentDao: NSObject {

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
     * Insert a document in the local database
     */
    func create(document: DocumentData) throws -> DocumentData {
        
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
        
        if sqlite3_prepare_v2(db, "INSERT INTO document (label, file_name, doc_id, file_ref, parts, status) VALUES (?, ?, ?, ?, ?, ?)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error preparing insert: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error prepare: \(errmsg)")
        }
        
        // insert
        // bind label
        if sqlite3_bind_text(statement, 1, document.label, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding label: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        
        // bind fileName
        if sqlite3_bind_text(statement, 2, document.fileName, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding fileName: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind docId
        if sqlite3_bind_text(statement, 3, document.docId, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding docId: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind fileRef
        if sqlite3_bind_text(statement, 4, document.fileRef, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding fileRef: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind parts
        if sqlite3_bind_int64(statement, 5, sqlite3_int64(document.parts)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding parts: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind status
        if sqlite3_bind_text(statement, 6, document.status, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding status: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error while inserting document: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error while inserting document: \(errmsg)")
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            LOGGER.error(msg: "error closing database")
        }
        
        db = nil
        
        LOGGER.info(msg: "Document inserted, id=\(document.id), fileName=\(document.fileName), label=\(document.label), docId=\(document.docId), fileRef=\(document.fileRef), parts=\(document.parts), status=\(document.status)")
        
        return document
    }
    
    /**
     * Update a document
     */
    func update(document: DocumentData) throws -> DocumentData {
        
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
        
        if sqlite3_prepare_v2(db, "UPDATE document SET status = ? WHERE id = ?", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error preparing insert: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error prepare: \(errmsg)")
        }
        
        // update
        // bind status
        if sqlite3_bind_text(statement, 1, document.status, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "failure binding status: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error binding: \(errmsg)")
        }
        // bind document id
        if sqlite3_bind_int64(statement, 2, sqlite3_int64(document.id)) != SQLITE_OK {
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
            LOGGER.error(msg: "error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            LOGGER.error(msg: "error closing database")
        }
        
        db = nil
        
        LOGGER.info(msg: "Document updated, id=\(document.id), status=\(document.status)")
        
        return document
    }
    
    /**
     * List all documents in the local database
     */
    func findDocumentById(id: Int) throws -> DocumentData? {
        
        // open database
        var db: OpaquePointer?
        if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
            LOGGER.error(msg: "Error opening database")
            throw DatabaseError.connectionError(message: "Cannot open connection to database)")
        }
        else {
            LOGGER.debug(msg: "Database connection successful")
        }
        
        // sql
        let sql = "select id, label, file_name, doc_id, file_ref, parts, status from document where id = " + String(id)
        
        // query
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error preparing select: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error preparing select: \(errmsg)")
        }
        
        var foundDoc: DocumentData? = nil
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            // id
            let id = sqlite3_column_int64(statement, 0)
            let idValue = Int(id)
            
            // label
            var labelValue = ""
            if let cString = sqlite3_column_text(statement, 1) {
                labelValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "labelValue not found")
            }
            
            // fileName
            var fileNameValue = ""
            if let cString = sqlite3_column_text(statement, 2) {
                fileNameValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "fileNameValue not found")
            }
            
            // doc id
            var docValue = ""
            if let cString = sqlite3_column_text(statement, 3) {
                docValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "docValue not found")
            }
            // fileref
            var fileValue = ""
            if let cString = sqlite3_column_text(statement, 4) {
                fileValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "fileValue not found")
            }
            
            // parts
            let parts = sqlite3_column_int64(statement, 5)
            let partsValue = Int(parts)
            
            // status
            var statusValue = ""
            if let cString = sqlite3_column_text(statement, 6) {
                statusValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "statusValue not found")
            }
            
            foundDoc = DocumentData(id: idValue, label: labelValue, fileName: fileNameValue, docId: docValue, fileRef: fileValue, parts: partsValue, status: statusValue)
            
            break
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            // TODO
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            // TODO
            LOGGER.error(msg: "Error closing database")
        }
        
        db = nil
        
        return foundDoc
    }
    
    /**
     * List all documents in the local database
     */
    func listAllDocuments() throws -> Array<DocumentData> {
        return try listDocuments(status: "")
    }
    
    /**
     * List new documents in the local database
     */
    func listDocumentsByStatus(status: String) throws -> Array<DocumentData> {
        return try listDocuments(status: status)
    }
    
    private func listDocuments(status: String) throws -> Array<DocumentData> {
        
        var docs: Array<DocumentData> = []
        
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
        var sql = "select id, label, file_name, doc_id, file_ref, parts, status from document"
        
        let addWhereClause = status.isEmpty
        
        if addWhereClause {
            // keep as is
        }
        else {
            sql += " where status = '" + status + "'"
        }
        
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
            
            // label
            var labelValue = ""
            if let cString = sqlite3_column_text(statement, 1) {
                labelValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "labelValue not found")
            }
            
            // fileName
            var fileNameValue = ""
            if let cString = sqlite3_column_text(statement, 2) {
                fileNameValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "fileNameValue not found")
            }
            
            // doc id
            var docValue = ""
            if let cString = sqlite3_column_text(statement, 3) {
                docValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "docValue not found")
            }
            // fileref
            var fileValue = ""
            if let cString = sqlite3_column_text(statement, 4) {
                fileValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "fileValue not found")
            }
            
            // parts
            let parts = sqlite3_column_int64(statement, 5)
            let partsValue = Int(parts)
            
            // status
            var statusValue = ""
            if let cString = sqlite3_column_text(statement, 6) {
                statusValue = String(cString: cString)
            } else {
                LOGGER.debug(msg: "statusValue not found")
            }
            
            // add to list
            let doc = DocumentData(id: idValue, label: labelValue, fileName: fileNameValue, docId: docValue, fileRef: fileValue, parts: partsValue, status: statusValue)
            
            docs.append(doc)
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
        
        return docs
    }
    
}
