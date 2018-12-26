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
    
    private let LOGGER = Logger.getInstance()
    
    private var fileSystemService = FileSystemService.getInstance()
    
    var dbDirUrl: URL
    //var db: OpaquePointer
    
    init(dataDir: String) {
        
        dbDirUrl = URL(fileURLWithPath: dataDir, isDirectory: true)
        
        super.init()
        
        initDatabaseDir(dataDir: dbDirUrl)
        
        initDatabaseSchema()
        
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
        
        let databaseFileUrl = dbDirUrl.appendingPathComponent(Constants.FILE_DATABASE)
        
        if fileSystemService.existFile(file: databaseFileUrl.path) {
            
            LOGGER.info(msg: "Database file found, list documents")
            
            // open database
            var db: OpaquePointer?
            if sqlite3_open(databaseFileUrl.path, &db) != SQLITE_OK {
                LOGGER.error(msg: "Error opening database")
                return
            }
            else {
                LOGGER.error(msg: "Database connection successful")
            }
            
            // query
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, "select id, name from documents", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing select: \(errmsg)")
                return
            }
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int64(statement, 0)
                print("id = \(id); ", terminator: "")
                
                if let cString = sqlite3_column_text(statement, 1) {
                    let name = String(cString: cString)
                    print("name = \(name)")
                } else {
                    print("name not found")
                }
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
        }
        else {
            
            LOGGER.info(msg: "database file not found, create tables")
            
            // open database
            var db: OpaquePointer?
            if sqlite3_open(databaseFileUrl.path, &db) != SQLITE_OK {
                LOGGER.error(msg: "Error opening database")
                return
            }
            else {
                LOGGER.error(msg: "Database connection successful")
            }
            
            // create table
            if sqlite3_exec(db, "create table if not exists documents (id integer primary key autoincrement, name text)", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
                return
            }
            
            // insert data
            var statement: OpaquePointer?
            
            if sqlite3_prepare_v2(db, "insert into documents (name) values (?)", -1, &statement, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            // insert 1
            if sqlite3_bind_text(statement, 1, "foo", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding foo: \(errmsg)")
                return
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting foo: \(errmsg)")
                return
            }
            
            // insert 2
            if sqlite3_reset(statement) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error resetting prepared statement: \(errmsg)")
                return
            }
            
            if sqlite3_bind_null(statement, 1) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding null: \(errmsg)")
                return
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting null: \(errmsg)")
                return
            }
            
            // insert 3
            if sqlite3_reset(statement) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error resetting prepared statement: \(errmsg)")
                return
            }
            
            if sqlite3_bind_text(statement, 1, "toto", -1, SQLITE_TRANSIENT) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding toto: \(errmsg)")
                return
            }
            
            if sqlite3_step(statement) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting toto: \(errmsg)")
                return
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
            
            LOGGER.info(msg: "inserted documents")
        }
    }
}
