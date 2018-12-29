//
//  SdbcTemplate.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation
import SQLite3

class SdbcTemplate: NSObject {

    private let LOGGER = Logger.getInstance()
    
    private let db = ConnectionPool.getConnection()
    
    func execute(sql: String, params: [String:Any] = [:]) throws {
    
        LOGGER.trace(msg: "execute, sql=\(sql), params=\(params)")
        
        let finalSql = try setParams(sql: sql, params: params)
        
        LOGGER.trace(msg: "finalSql=\(finalSql)")
        
        try self.db.execute(sql: finalSql)
    }
    
    func insertAndReturnKey(sql: String, params: [String:Any] = [:]) throws -> Int {
        
        LOGGER.trace(msg: "execute, sql=\(sql), params=\(params)")
        
        let finalSql = try setParams(sql: sql, params: params)
        
        LOGGER.trace(msg: "finalSql=\(finalSql)")
        
        return try self.db.insertRowAndReturnKey(sql: finalSql)
    }
    
    func query<T>(sql: String, params: [String: Any], rowMapper: (OpaquePointer) -> T) throws -> [T] {
        
        LOGGER.trace(msg: "query, sql=\(sql), params=\(params)")
        
        let finalSql = try setParams(sql: sql, params: params)
        
        LOGGER.trace(msg: "finalSql=\(finalSql)")
        
        return try self.db.query(sql: finalSql, rowMapper: rowMapper)
    }
    
    private func setParams(sql: String, params: [String: Any]) throws -> String {
        
        var finalSql = sql
        
        for (key, value) in params {
            
            let sqlValue = try paramToString(param: value)
            
            LOGGER.trace(msg: "replacing instances of=:\(key) with=\(sqlValue)")
            finalSql = finalSql.replacingOccurrences(of: ":\(key)", with: sqlValue)
        }
        
        return finalSql
    }
    
    private func paramToString(param: Any) throws -> String {
        
        if let str = param as? String {
            // obj is a String
            return "'\(str)'"
        }
        if let int = param as? Int {
            // obj is a Int
            return "\(int)"
        }
        else {
            // not implemented
            LOGGER.error(msg: "Object type not implement: \(param)")
            throw DatabaseError.sqlError(message: "Parameter type is not implemented")
        }
    }
}
