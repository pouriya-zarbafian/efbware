//
//  DatabaseService.swift
//  db-test
//
//  Created by Pouriya Zarbafian on 25/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit
import SQLite3

class DatabaseFacade: NSObject {
    
    static private let instance: DatabaseFacade = {
       let dbService = DatabaseFacade()
        return dbService
    }()
    
    private let LOGGER = Logger.getInstance()
    
    private var fileSystemService = FileSystemService.getInstance()
    
    private var documentDao: DocumentDao
    private var documentPartDao: DocumentPartDao
    
    static func getInstance() -> DatabaseFacade {
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
            LOGGER.error(msg: "updateDocument: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     * Reset a document in the local database
     */
    func resetDocument(document: DocumentData) -> DocumentData? {
        
        do {
            return try self.documentDao.reset(document: document)
        }
        catch {
            LOGGER.error(msg: "resetDocument: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     * Delete a document in the local database
     */
    func deleteDocument(document: DocumentData) {
        
        do {
            try self.documentDao.delete(document: document)
        } catch {
            LOGGER.error(msg: "deleteDocument: \(error.localizedDescription)")
            return
        }
    }
    
    /**
     * Find a document in the local database
     */
    func findDocumentById(id: Int) -> DocumentData? {
        
        do {
            return try self.documentDao.findDocumentById(id: id)
        }
        catch {
            LOGGER.error(msg: "findDocumentById: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     * Find a document in the local database
     */
    func findDeletedDocumentByDocument(docId: String) -> DocumentData? {
        
        do {
            return try self.documentDao.findDeletedDocumentByDocument(docId: docId)
        }
        catch {
            LOGGER.error(msg: "findDocumentByDocument: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     * List all documents in the local database
     */
    func listDeletedDocuments() -> Array<DocumentData> {
        do {
            return try self.documentDao.listDeletedDocuments()
        }
        catch {
            LOGGER.error(msg: "listDeletedDocuments: \(error.localizedDescription)")
            return []
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
            LOGGER.error(msg: "listAllDocuments: \(error.localizedDescription)")
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
            LOGGER.error(msg: "listDocumentsByStatus: \(error.localizedDescription)")
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
            LOGGER.error(msg: "insertDocumentPart: \(error.localizedDescription)")
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
            LOGGER.error(msg: "updateDocumentPart: \(error.localizedDescription)")
            return nil
        }
    }
    
    /**
     * Delete document parts in the local database
     */
    func deleteDocumentPartByDocument(document: DocumentData) {
        
        do {
            try self.documentPartDao.deleteByDocument(document: document)
        }
        catch {
            LOGGER.error(msg: "deleteDocumentPartByDocument: \(error.localizedDescription)")
            return
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
            LOGGER.error(msg: "listDocumentParts: \(error.localizedDescription)")
            return []
        }
    }
}
