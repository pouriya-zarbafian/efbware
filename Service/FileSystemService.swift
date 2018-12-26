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
    
    static private let instance: FileSystemService = {
        let fss = FileSystemService()
        return fss;
    }()
    
    static func getInstance() -> FileSystemService {
        return instance
    }
    
    var documentsUrl: URL
    var appDirUrl: URL
    
    private init() {
        
        LOGGER.debug(msg: "FileSystemService.init")
        
        documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        LOGGER.debug(msg: "documentsUrl=\(documentsUrl)")
        
        appDirUrl = documentsUrl.appendingPathComponent(Constants.DIR_APPLICATION)
        
        if(existDir(dir: appDirUrl.path)) {
            LOGGER.info(msg: "app dir found")
        }
        else {
            createDir(dir: appDirUrl)
            LOGGER.info(msg: "app dir created")
        }
    }
    
    func createDir(dir: URL) {
        
        LOGGER.debug(msg: "createDir, dir=\(dir)")
        
        do {
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: false, attributes: nil)
            LOGGER.info(msg: "Dir created successfully")
        } catch let error as NSError {
            print("Error while creating dir \(documentsUrl.path): \(error.description)")
        }
    }
    
    func existFile(file: String)  -> Bool {
        
        LOGGER.debug(msg: "existFile, file=\(file)")
        
        let res = FileManager.default.fileExists(atPath: file)
        
        LOGGER.debug(msg: "existFile, res=\(res)")
        
        return res
    }
    
    func existDir(dir: String)  -> Bool {
        
        LOGGER.debug(msg: "existDir, dir=\(dir)")
        
        var isDir : ObjCBool = true
        
        let res = FileManager.default.fileExists(atPath: dir, isDirectory: &isDir)
     
        LOGGER.debug(msg: "existDir, res=\(res)")
        
        return res
    }
    
    func writeSid(sid: String) {
            
        let sidFile = Constants.FILE_SID
        
        let sidFileUrl = appDirUrl.appendingPathComponent(sidFile)
        
        //writing
        do {
            try sid.write(to: sidFileUrl, atomically: false, encoding: .utf8)
            LOGGER.error(msg: "Sid written to cache file")
        }
        catch {
            /* error handling here */
            LOGGER.error(msg: "Error writing sid to cache file")
        }
    }
    
    func readSid() -> String {
        
        let sidFile = Constants.FILE_SID
        
        let sidFileUrl = appDirUrl.appendingPathComponent(sidFile)
        
        //reading
        do {
            let sid = try String(contentsOf: sidFileUrl, encoding: .utf8)
            LOGGER.error(msg: "Sid read from cache file")
            return sid
        }
        catch {
            /* error handling here */
            LOGGER.error(msg: "Error reading sid from cache file")
            return ""
        }
    }
}
