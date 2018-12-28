//
//  ConnectionPool.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class ConnectionPool: NSObject {

    private let LOGGER = Logger.getInstance()
    
    private static let instance: ConnectionPool = {
        let connectionPool = try! ConnectionPool(size: 1)
        return connectionPool
    }()
    
    private let databaseConnection: DatabaseConnection?
    
    private init(size: Int) throws {
        // this should only be executed once!
        do {
            try databaseConnection = DatabaseConnection()
        }
        catch {
            LOGGER.error(msg: "💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢")
            LOGGER.error(msg: "Could not open database connection")
            LOGGER.error(msg: "💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢💢")
            databaseConnection = nil
        }
    }
    
    //static
    static func getConnection() -> DatabaseConnection {
        return instance.databaseConnection!
    }
    
    static func close() {
        instance.databaseConnection!.close()
    }
}
