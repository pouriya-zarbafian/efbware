//
//  SchemaDao.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 26/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation
import SQLite3

class SchemaDao: NSObject {

    private let LOGGER = Logger.getInstance()
    
    private let dbFileUrl: URL
    
    init(databaseFileUrl: URL) {
        self.dbFileUrl = databaseFileUrl
        LOGGER.info(msg: "dbFileUrl=\(dbFileUrl)")
        super.init()
    }
    
    func createTable() throws {
        
        // open database
        var db: OpaquePointer?
        if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
            LOGGER.error(msg: "Error opening database")
            throw DatabaseError.connectionError(message: "Error opening database")
        }
        else {
            LOGGER.debug(msg: "Database connection successful")
        }
        
        // create tables
        // create table documents
        if sqlite3_exec(db, "CREATE TABLE document (id integer primary key autoincrement, label text, file_name text, doc_id text, file_ref text, parts integer, status text, UNIQUE(doc_id))", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error creating table: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error creating table: \(errmsg)")
        }
        // create table document_part
        if sqlite3_exec(db, "CREATE TABLE document_part (id integer primary key autoincrement, part_number integer, document integer, status text, FOREIGN KEY(document) REFERENCES document(id), UNIQUE(document, part_number))", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error creating table: \(errmsg)")
            throw DatabaseError.sqlError(message: "Error creating table: \(errmsg)")
        }
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            LOGGER.error(msg: "Error closing database")
        }
        
        db = nil
    }
}
