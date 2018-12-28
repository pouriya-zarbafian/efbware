//
//  SchemaDao.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 26/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation
import SQLite3

class SchemaDao: NSObject {

    private let LOGGER = Logger.getInstance()
    
    private let sdbcTemplate: SdbcTemplate
    
    override init() {
        self.sdbcTemplate = SdbcTemplate()
        super.init()
    }
    
    
}
