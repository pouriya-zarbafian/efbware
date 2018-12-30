//
//  DatabaseConnection.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//
import Foundation
import SQLite3

class DatabaseConnection {

    private let LOGGER = Logger.getInstance()
    
    private let fileSystemService = FileSystemService.getInstance()
    
    // paths
    private var dbDirUrl: URL
    private var dbFileUrl: URL
    
    // open database file
    private var db: OpaquePointer?
    
    let semaphore = DispatchSemaphore(value: 1)
    
    init() throws {
    
        // DB dir
        var appDirUrl = URL(fileURLWithPath: fileSystemService.appDirUrl.path, isDirectory: true)
        appDirUrl.appendPathComponent(Constants.DIR_DATABASE)
        
        dbDirUrl = appDirUrl
        
        // DB file
        dbFileUrl = dbDirUrl.appendingPathComponent(Constants.FILE_DATABASE)
        
        LOGGER.info(msg: "Database file path is: \(dbDirUrl.path)")
        
        try initDatabaseDir(dataDir: dbDirUrl)
        
        LOGGER.info(msg: "💚 Database directory initialized")
        
        var createSchema = false
        
        if fileSystemService.existFile(file: dbFileUrl.path) {
            
            LOGGER.info(msg: "💙 Database file found at: \(dbFileUrl.path)")
        }
        else {
            createSchema = true
            LOGGER.info(msg: "Database schema scheduled for creation")
        }
        
        if sqlite3_open(dbFileUrl.path, &self.db) != SQLITE_OK {
            LOGGER.error(msg: "💔 Error opening database connection")
            throw DatabaseError.connectionError(message: "Error opening database connection")
        }
        else {
            LOGGER.info(msg: "💚 Database connection opened successful")
        }
        
        if createSchema {
            do {
                try createTable()
                LOGGER.info(msg: "💚 Database schema created successfully")
            } catch {
                LOGGER.error(msg: "💔 Error initializing database schema: \(error.localizedDescription)")
                throw DatabaseError.sqlError(message: "Error initializing database schema")
            }
        }

    }
    
    // close database file
    func close() -> Void {
        
        // close database
        if sqlite3_close(self.db) != SQLITE_OK {
            LOGGER.error(msg: "💔 Error closing database connection")
        }
        else {
            LOGGER.info(msg: "💚 Database connection closed successfully")
        }
        
        self.db = nil
    }
    
    func databaseFileUrl() -> URL {
        return URL(fileURLWithPath: dbFileUrl.path)
    }
    
    private func initDatabaseDir(dataDir: URL) throws {
        
        if(fileSystemService.existDir(dir: dataDir.path)) {
            LOGGER.info(msg: "💙 Database directory found: \(dataDir.path)")
        }
        else {
            LOGGER.info(msg: "Creating database diretory, dir=\(dataDir.path)")
            
            do {
                try fileSystemService.createDir(dir: dataDir)
            } catch {
                LOGGER.error(msg: "💔 Error creating database diretory")
                throw FileSystemError.directoryCreationError(message: error.localizedDescription)
            }
            
            LOGGER.info(msg: "💚 Database directory created")
        }
    }
    
    func createTable() throws {
        
        // create table documents
        let sqlDocs = "CREATE TABLE document (id integer primary key autoincrement, label text, file_name text, doc_id text, file_ref text, parts integer, status text, deleted integer DEFAULT 0, UNIQUE(doc_id))"
        
        
        // create table document_part
        let sqlParts = "CREATE TABLE document_part (id integer primary key autoincrement, part_number integer, document integer, status text, FOREIGN KEY(document) REFERENCES document(id), UNIQUE(document, part_number))"
        
        try execute(sql: sqlDocs)
        
        try execute(sql: sqlParts)
    }
    
    func execute(sql: String) throws {
        
        semaphore.wait()
        
        if sqlite3_exec(self.db, sql, nil, nil, nil) != SQLITE_OK {
            
            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
            LOGGER.error(msg: "Error during execute: \(errmsg)")
            
            semaphore.signal()
            
            throw DatabaseError.sqlError(message: "Error executing SQL: \(errmsg)")
        }
        else {
            LOGGER.trace(msg: "SQL executed successfully")
            
            semaphore.signal()
        }
    }
    
    func insertRowAndReturnKey(sql: String) throws -> Int {
        
        semaphore.wait()
        
        if sqlite3_exec(self.db, sql, nil, nil, nil) != SQLITE_OK {
            
            let errmsg = String(cString: sqlite3_errmsg(self.db)!)
            LOGGER.error(msg: "Error during execute: \(errmsg)")
            
            semaphore.signal()
            
            throw DatabaseError.sqlError(message: "Error executing SQL: \(errmsg)")
        }
        else {
            LOGGER.trace(msg: "SQL executed successfully")
            
            let genId64 = sqlite3_last_insert_rowid(self.db)
            
            let genId = Int(genId64)
            
            semaphore.signal()
            
            LOGGER.trace(msg: "🔑 Generated ID: \(genId)")
            
            return genId
        }
    }
    
    func query<T>(sql: String, rowMapper: (OpaquePointer) throws -> T) throws -> [T] {
        
        semaphore.wait()
        
        // query
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(self.db, sql, -1, &statement, nil) != SQLITE_OK {
            
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error preparing select: \(errmsg)")
            
            semaphore.signal()
            
            throw DatabaseError.sqlError(message: "Error preparing select: \(errmsg)")
        }
        
        var rows: Array<T> = []
        
        while sqlite3_step(statement) == SQLITE_ROW {
            
            do {
                let entity = try rowMapper(statement!)
                rows.append(entity)
            } catch {
                semaphore.signal()
                throw error
            }
        }
        
        // finalize
        if sqlite3_finalize(statement) != SQLITE_OK {
            
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            LOGGER.error(msg: "Error finalizing prepared statement: \(errmsg)")
            
            semaphore.signal()
            
            throw DatabaseError.sqlError(message: "Error finalizing prepared statement: \(errmsg)")
        }
        
        semaphore.signal()
        
        return rows
    }
}
