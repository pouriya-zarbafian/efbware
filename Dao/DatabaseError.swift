//
//  DatabaseError.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 26/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

enum DatabaseError: Error {
    case connectionError(message: String)
    case sqlError(message: String)
}
