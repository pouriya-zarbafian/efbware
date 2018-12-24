//
//  FileSystemService.swift
//  demoefb
//
//  Created by Pouriya Zarbafian on 23/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import Foundation

class FileSystemService {
    
    private let LOGGER = Logger.getInstance()
    
    let DIR_EFB = "EFB"
    let DIR_MANUALS = "MANUALS"
    let DIR_TECHLOGS = "TECHLOGS"
    
    let userURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init() {
        LOGGER.debug(msg: "FileSystemService.init, userURL=\(userURL)")
        
        let efbURL = userURL.appendingPathComponent(DIR_EFB)
        
        if(existDir(dir: efbURL.path)) {
            LOGGER.info(msg: "EFB dir found")
        }
        else {
            createDir(dir: efbURL)
            LOGGER.info(msg: "EFB dir created")
        }
    }
    
    private func createDir(dir: URL) {
        
        LOGGER.debug(msg: "createDir, dir=\(dir)")
        
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil)
            LOGGER.info(msg: "Dir created successfully")
        } catch let error as NSError {
            print("Error while creating dir \(userURL.path): \(error.description)")
        }
    }
    
    func existDir(dir: String)  -> Bool {
        
        LOGGER.debug(msg: "existDir, dir=\(dir)")
        
        var isDir : ObjCBool = false
        
        let res = FileManager.default.fileExists(atPath: dir, isDirectory: &isDir)
     
        LOGGER.debug(msg: "existDir, res=\(res)")
        
        return res
    }
}
