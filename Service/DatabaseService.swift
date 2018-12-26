//
//  DatabaseService.swift
//  db-test
//
//  Created by Pouriya Zarbafian on 25/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit
import SQLite3

class DatabaseService: NSObject {
    
    static private let instance: DatabaseService = {
       let dbService = DatabaseService()
        return dbService
    }()
    
    private let LOGGER = Logger.getInstance()
    
    private var fileSystemService = FileSystemService.getInstance()
    
    var dbDirUrl: URL
    var dbFileUrl: URL
    //var db: OpaquePointer
    
    static func getInstance() -> DatabaseService {
        return instance
    }
    
    override private init() {
        
        var appDbUrl = URL(fileURLWithPath: fileSystemService.appDirUrl.path, isDirectory: true)
        appDbUrl.appendPathComponent(Constants.DIR_DATABASE)
        
        dbDirUrl = appDbUrl
        dbFileUrl = dbDirUrl.appendingPathComponent(Constants.FILE_DATABASE)
        
        super.init()
        
        initDatabaseDir(dataDir: dbDirUrl)
        
        initDatabaseSchema()
        
    }
    
    func databaseFileUrl() -> URL {
        return dbDirUrl.appendingPathComponent(Constants.FILE_DATABASE)
    }
    
    private func initDatabaseDir(dataDir: URL) {
        
        if(fileSystemService.existDir(dir: dataDir.path)) {
            LOGGER.info(msg: "dir found: \(dataDir.path)")
        }
        else {
            LOGGER.info(msg: "creating diretory DATABASE, dir=\(dataDir.path)")
            fileSystemService.createDir(dir: dataDir)
            LOGGER.info(msg: "DATABASE directory created")
        }
    }
    
    // TODO
    internal let SQLITE_STATIC = unsafeBitCast(0, to: sqlite3_destructor_type.self)
    internal let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)

    private func initDatabaseSchema() {
        
        if fileSystemService.existFile(file: dbFileUrl.path) {
            
            LOGGER.info(msg: "Database file found, list documents")
            
            // open database
            var db: OpaquePointer?
            if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
                LOGGER.error(msg: "Error opening database")
                return
            }
            else {
                LOGGER.error(msg: "Database connection successful")
            }
            
            // close database
            if sqlite3_close(db) != SQLITE_OK {
                print("error closing database")
            }
            
            db = nil
        }
        else {
            
            LOGGER.info(msg: "database file not found, create tables")
            
            // open database
            var db: OpaquePointer?
            if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
                LOGGER.error(msg: "Error opening database")
                return
            }
            else {
                LOGGER.error(msg: "Database connection successful")
            }
            
            // create table
            // create table if not exists documents
            if sqlite3_exec(db, "create table documents (id integer primary key autoincrement, label text, doc_id text, file_ref text, parts integer, status text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
                return
            }
            
            // insert data
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, "insert into documents (label, doc_id, file_ref, parts, status) values (?, ?, ?, ?, ?)", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            /*
            // insert
            // bind label
            if sqlite3_bind_text(statement, 1, "eu labelle", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding label: \(errmsg)")
                return
            }
            // bind docId
            if sqlite3_bind_text(statement, 2, "58", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding docId: \(errmsg)")
                return
            }
            // bind fileRef
            if sqlite3_bind_text(statement, 3, "theFileRef0EEF", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding fileRef: \(errmsg)")
                return
            }
            // bind parts
            if sqlite3_bind_int64(statement, 4, 22) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding parts: \(errmsg)")
                return
            }
            // bind status
            if sqlite3_bind_text(statement, 5, "NEW", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding status: \(errmsg)")
                return
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting label: \(errmsg)")
                return
            }
            
            // finalize
            if sqlite3_finalize(statement) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error finalizing prepared statement: \(errmsg)")
            }
            
            statement = nil
            */
            
            // close database
            if sqlite3_close(db) != SQLITE_OK {
                print("error closing database")
            }
            
            db = nil
            
            LOGGER.info(msg: "inserted documents")
        }
    }
    
    /**
     * Insert a document in the local database
     */
    func insertDocument(document: DocumentData) -> DocumentData {
        
        // open database
        var db: OpaquePointer?
        if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
            LOGGER.error(msg: "Error opening database")
            //TODO
        }
        else {
            LOGGER.error(msg: "Database connection successful")
        }
        
        // insert data
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, "insert into documents (label, doc_id, file_ref, parts, status) values (?, ?, ?, ?, ?)", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            // TODO
        }
        
        // insert
        // bind label
        if sqlite3_bind_text(statement, 1, document.label, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding label: \(errmsg)")
            // TODO
        }
        // bind docId
        if sqlite3_bind_text(statement, 2, document.docId, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding docId: \(errmsg)")
            // TODO
        }
        // bind fileRef
        if sqlite3_bind_text(statement, 3, document.fileRef, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding fileRef: \(errmsg)")
            // TODO
        }
        // bind parts
        if sqlite3_bind_int64(statement, 4, sqlite3_int64(document.parts)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding parts: \(errmsg)")
            // TODO
        }
        // bind status
        if sqlite3_bind_text(statement, 5, document.status, -1, SQLITE_TRANSIENT) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding status: \(errmsg)")
            // TODO
        }
        
        if sqlite3_step(statement) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting label: \(errmsg)")
            // TODO
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            print("error closing database")
        }
        
        db = nil
        
        LOGGER.debug(msg: "Document inserted, id=\(document.id), label=\(document.label), docId=\(document.docId), fileRef=\(document.fileRef), parts=\(document.parts), status=\(document.status)")
        
        return document
    }
    
    /**
     * List all documents in the local database
     */
    func listDocuments() -> Array<DocumentData> {
        
        var docs: Array<DocumentData> = []
        
        // open database
        var db: OpaquePointer?
        if sqlite3_open(dbFileUrl.path, &db) != SQLITE_OK {
            LOGGER.error(msg: "Error opening database")
            // TODO
            return docs
        }
        else {
            LOGGER.error(msg: "Database connection successful")
        }
        
        // query
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, "select id, label, doc_id, file_ref, parts, status from documents", -1, &statement, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            // TODO
            return docs
        }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            // id
            let id = sqlite3_column_int64(statement, 0)
            let idValue = Int(id)
            print("idValue= \(idValue); ", terminator: "")
            
            // label
            var labelValue = ""
            if let cString = sqlite3_column_text(statement, 1) {
                labelValue = String(cString: cString)
                print("labelValue = \(labelValue)")
            } else {
                print("labelValue not found")
            }
            
            // doc id
            var docValue = ""
            if let cString = sqlite3_column_text(statement, 2) {
                docValue = String(cString: cString)
                print("docValue = \(docValue)")
            } else {
                print("docValue not found")
            }
            // fileref
            var fileValue = ""
            if let cString = sqlite3_column_text(statement, 3) {
                fileValue = String(cString: cString)
                print("fileValue = \(fileValue)")
            } else {
                print("fileValue not found")
            }
            
            // parts
            let parts = sqlite3_column_int64(statement, 4)
            let partsValue = Int(parts)
            print("partsValue = \(partsValue); ", terminator: "")
            
            // status
            var statusValue = ""
            if let cString = sqlite3_column_text(statement, 5) {
                statusValue = String(cString: cString)
                print("statusValue = \(statusValue)")
            } else {
                print("statusValue not found")
            }
            
            // add to list
            let doc = DocumentData(id: idValue, label: labelValue, docId: docValue, fileRef: fileValue, parts: partsValue, status: statusValue)
            
            docs.append(doc)
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            // TODO
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("Error finalizing prepared statement: \(errmsg)")
        }
        
        statement = nil
        
        // close database
        if sqlite3_close(db) != SQLITE_OK {
            // TODO
            print("Error closing database")
        }
        
        db = nil
        
        return docs
    }
}
