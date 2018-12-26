//
//  Logger.swift
//  demoefb
//
//  Created by Pouriya Zarbafian on 23/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation

class Logger {
    
    // MARK: properties
    private static var instance: Logger = {
        let logger = Logger()
        return logger
    }()
    
    private var logLevel: LogLevel = .debug
    
    private enum LogLevel {
        case debug
        case info
        case warn
        case error
    }
    
    static func getInstance() -> Logger {
        return Logger.instance
    }
    
    private init() {
        print("Logger.init")
    }
    
    func debug(msg: String) {
        log(level: .debug, msg: msg)
    }
    
    func info(msg: String) {
        log(level: .info, msg: msg)
    }
    
    func warn(msg: String) {
        log(level: .warn, msg: msg)
    }
    
    func error(msg: String) {
        log(level: .error, msg: msg)
    }
    
    private func log(level: LogLevel, msg: String) {
        
        let msgLevel = getValue(level: level)
        let currentLevel = getValue(level: logLevel)
        
        if(msgLevel >= currentLevel) {
            logEx(log: msg)
        }
    }
    
    private func logEx(log: String) {
        print(log)
    }
    
    private func getValue(level: LogLevel) -> Int {

        switch level {
        case .debug:
            return 1
        case .info:
            return 2
        case .warn:
            return 3
        case .error:
            return 4
        }
    }
}
