//
//  ConnectionPool.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class ConnectionPool: NSObject {

    static let instance: ConnectionPool = {
        let connPool = ConnectionPool()
        return connPool
    }()
    
    private override init() {
        // TODO: get db file
        
    }
    
    //static 
}
