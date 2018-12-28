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
    
    private let sdbcTemplate = SdbcTemplate()
    
    /**
     * Insert a document in the local database
     */
    func create(document: DocumentData) throws -> DocumentData {
        
        let sql = "INSERT INTO document (label, file_name, doc_id, file_ref, parts, status) VALUES (:label, :filname, :document, :fileref, :parts, :status)"
        
        var params: [String:Any] = [:]
        params["label"] = document.label
        params["filname"] = document.fileName
        params["document"] = document.docId
        params["fileref"] = document.fileRef
        params["parts"] = document.parts
        params["status"] = document.status
        
        // TODO: return generated id
        try sdbcTemplate.execute(sql: sql, params: params)
        
        LOGGER.info(msg: "Document inserted, id=\(document.id), fileName=\(document.fileName), label=\(document.label), docId=\(document.docId), fileRef=\(document.fileRef), parts=\(document.parts), status=\(document.status)")
        
        return document
    }
    
    /**
     * Update a document
     */
    func update(document: DocumentData) throws -> DocumentData {
        
        let sql = "UPDATE document SET status = :status WHERE id = :id"
        
        var params: [String:Any] = [:]
        params["id"] = document.id
        params["status"] = document.status
        
        // TODO: return generated id
        try sdbcTemplate.execute(sql: sql, params: params)
        
        LOGGER.info(msg: "Document updated, id=\(document.id), status=\(document.status)")
        
        return document
    }
    
    /**
     * List all documents in the local database
     */
    func findDocumentById(id: Int) throws -> DocumentData? {
        
        let docs = try sdbcTemplate.query(sql: SelectDocument.getSqlWhereId(), params: SelectDocument.getParams(id: id), rowMapper: SelectDocument.DocumentRowMapper)
        
        if docs.count > 0 {
            return docs[0]
        }
        
        return nil
    }
    
    /**
     * List all documents in the local database
     */
    func listAllDocuments() throws -> Array<DocumentData> {
        return try genereicListDocuments(status: "")
    }
    
    /**
     * List new documents in the local database
     */
    func listDocumentsByStatus(status: String) throws -> Array<DocumentData> {
        return try genereicListDocuments(status: status)
    }
    
    private func genereicListDocuments(status: String) throws -> Array<DocumentData> {
        
        // sql
        var sql = SelectDocument.getSql()
        var params: [String: Any] = [:]
        
        let addWhereClause = !status.isEmpty
        
        if addWhereClause {
            sql = SelectDocument.getSqlWhereStatus()
            params = SelectDocument.getParams(status: status)
        }
        
        let docs: [DocumentData] = try sdbcTemplate.query(sql: sql, params: params, rowMapper: SelectDocument.DocumentRowMapper)
        
        return docs
    }
    
}
