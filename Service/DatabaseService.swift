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
    
    private var documentDao: DocumentDao
    private var schemaDao: SchemaDao
    
    let dbDirUrl: URL
    let dbFileUrl: URL
    
    static func getInstance() -> DatabaseService {
        return instance
    }
    
    override private init() {
        
        var appDbUrl = URL(fileURLWithPath: fileSystemService.appDirUrl.path, isDirectory: true)
        appDbUrl.appendPathComponent(Constants.DIR_DATABASE)
        
        dbDirUrl = appDbUrl
        dbFileUrl = dbDirUrl.appendingPathComponent(Constants.FILE_DATABASE)
        documentDao = DocumentDao(databaseFileUrl: dbFileUrl)
        schemaDao = SchemaDao(databaseFileUrl: dbFileUrl)
        
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

    private func initDatabaseSchema() {
        
        if fileSystemService.existFile(file: dbFileUrl.path) {
            
            LOGGER.info(msg: "Database file found")
            
        }
        else {
            
            LOGGER.info(msg: "Database file not found, create tables")
            
            do {
                try schemaDao.createTable()
            } catch {
                LOGGER.error(msg: "Could not initialize schema")
            }
        }
    }
    
    /**
     * Insert a document in the local database
     */
    func insertDocument(document: DocumentData) -> DocumentData? {
        
        do {
            return try self.documentDao.createDocument(document: document)
        }
        catch {
            return nil
        }
    }
    
    /**
     * List all documents in the local database
     */
    func findDocumentById(id: Int) -> DocumentData? {
        
        do {
            return try self.documentDao.findDocumentById(id: id)
        }
        catch {
            return nil
        }
    }
    
    /**
    * List all documents in the local database
    */
    func listAllDocuments() -> Array<DocumentData> {
        do {
            return try self.documentDao.listAllDocuments()
        }
        catch {
            return []
        }
    }
    
    /**
     * List new documents in the local database
     */
    func listNewDocuments() -> Array<DocumentData> {
        do {
            return try self.documentDao.listNewDocuments()
        }
        catch {
            return []
        }
    }    
}
