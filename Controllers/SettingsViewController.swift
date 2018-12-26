//
//  SettingsViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    private let LOGGER = Logger.getInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOGGER.debug(msg: "SettingsViewController.viewDidLoad")
    }
    
    // MARK: UI
    
    @IBAction func listDatabaseFilesButton(_ sender: UIButton) {
        
        print("PRESSED LIST")
        
        var userURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        userURL.appendPathComponent(Constants.DIR_APPLICATION)
        userURL.appendPathComponent(Constants.DIR_DATABASE)
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: userURL, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                
                print("Found file: \(file.path)")
            }
            
        } catch {
            print("Error while enumerating files \(userURL.path): \(error.localizedDescription)")
        }
    }
    
    @IBAction func resetAppDirButton(_ sender: UIButton) {
        
        print("PRESSED RESET")
        
        var userURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        userURL.appendPathComponent(Constants.DIR_APPLICATION)
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: userURL, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                
                print("Deleting file: \(file.path)")
                
                do {
                    try FileManager.default.removeItem(atPath: file.path)
                    print("file deleted")
                }
                catch {
                    print("Error deleting file: \(file.path)")
                }
                
                do {
                    try FileManager.default.removeItem(atPath: userURL.path)
                    print("app dir deleted")
                }
                catch {
                    print("Error deleting file: \(file.path)")
                }
            }
            
        } catch {
            print("Error while enumerating files \(userURL.path): \(error.localizedDescription)")
        }
    }
    @IBAction func databaseButton(_ sender: UIButton) {
        
        LOGGER.debug(msg: "PRESSED DB")
        
        var docsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        docsUrl.appendPathComponent(Constants.DIR_APPLICATION)
        docsUrl.appendPathComponent(Constants.DIR_DATABASE)
        
        LOGGER.debug(msg: "databaseDirectory=\(docsUrl.path)")
        
        _ = DatabaseService(dataDir: docsUrl.path)
    }
    
    @IBAction func deleteDatabaseFileButton(_ sender: UIButton) {
        
        print("PRESSED DELETE")
        
        var userURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        userURL.appendPathComponent(Constants.DIR_APPLICATION)
        userURL.appendPathComponent(Constants.DIR_DATABASE)
        userURL.appendPathComponent(Constants.FILE_DATABASE)
        
        if FileSystemService.getInstance().existFile(file: userURL.path) {
            print("db file found, deleting...")
            do {
                try FileManager.default.removeItem(atPath: userURL.path)
                print("db file deleted")
            }
            catch {
                print("error deleting db file")
            }
        }
        else {
            print("error db file not found!")
        }
    }
}
