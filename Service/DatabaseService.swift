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
    private var documentPartDao: DocumentPartDao
    
    static func getInstance() -> DatabaseService {
        return instance
    }
    
    override private init() {

        documentDao = DocumentDao()
        documentPartDao = DocumentPartDao()
        
        super.init()
    }
    
    /**
     * Insert a document in the local database
     */
    func insertDocument(document: DocumentData) throws -> DocumentData {
        
        return try self.documentDao.create(document: document)
    }
    
    /**
     * Update a document in the local database
     */
    func updateDocument(document: DocumentData) -> DocumentData? {
        
        do {
            return try self.documentDao.update(document: document)
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
    func listDocumentsByStatus(status: String) -> Array<DocumentData> {
        do {
            return try self.documentDao.listDocumentsByStatus(status: status)
        }
        catch {
            return []
        }
    }
    
    /**
     * Insert a document part in the local database
     */
    func insertDocumentPart(part: DocumentPartData) -> DocumentPartData? {
        
        do {
            return try self.documentPartDao.create(part: part)
        }
        catch {
            return nil
        }
    }
    
    /**
     * Update a document part in the local database
     */
    func updateDocumentPart(part: DocumentPartData) -> DocumentPartData? {
        
        do {
            return try self.documentPartDao.update(part: part)
        }
        catch {
            return nil
        }
    }
    
    /**
     * List all documents parts for a documents
     */
    func listDocumentParts(documentId: Int, status: String) -> Array<DocumentPartData> {
        do {
            return try self.documentPartDao.listPartsByStatus(document: documentId, status: status)
        }
        catch {
            return []
        }
    }
}
