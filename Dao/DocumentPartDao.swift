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
    
    private let sdbcTemplate = SdbcTemplate()

    /**
     * Insert a document part in the local database
     */
    func create(part: DocumentPartData) throws -> DocumentPartData {
        
        let sql = "INSERT INTO document_part (part_number, document, status) VALUES (:part, :document, :status)"
        
        var params: [String:Any] = [:]
        params["part"] = part.partNumber
        params["document"] = part.documentId
        params["status"] = part.status
        
        let generatedId = try sdbcTemplate.insertAndReturnKey(sql: sql, params: params)
        
        part.id = generatedId
        
        LOGGER.info(msg: "Document part inserted, id=\(part.id), label=\(part.partNumber), docId=\(part.documentId), status=\(part.status)")
        
        return part
    }
    
    /**
     * Update a document part
     */
    func update(part: DocumentPartData) throws -> DocumentPartData {
        
        let sql = "UPDATE document_part SET status = :status WHERE id = :id"
        
        var params: [String:Any] = [:]
        params["id"] = part.id
        params["status"] = part.status
        
        // TODO: return generated id
        try sdbcTemplate.execute(sql: sql, params: params)
        
        return part
    }
    
    /**
     * Delete a document part
     */
    func deleteByDocument(document: DocumentData) throws {
        
        let sql = "DELETE FROM document_part WHERE document = :document"
        
        var params: [String:Any] = [:]
        params["document"] = document.id
        
        try sdbcTemplate.execute(sql: sql, params: params)
    }
    
    /**
     * List new document parts in the local database
     */
    func listPartsByStatus(document: Int, status: String) throws -> Array<DocumentPartData> {
        
        let sql = "SELECT id, part_number, document, status from document_part WHERE document = :document AND status = :status"
        var params: [String:Any] = [:]
        params["document"] = document
        params["status"] = status
        
        let parts: [DocumentPartData] = try sdbcTemplate.query(sql: sql, params: params, rowMapper: SelectDocumentPart.DocumentPartRowMapper)
        
        return parts
    }
}
