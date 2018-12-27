//
//  FileSystemError.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 27/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

enum FileSystemError: Error {

    case fileCreationError(message: String)
    case directoryCreationError(message: String)
    case cannotAcquireHandle(message: String)
}
