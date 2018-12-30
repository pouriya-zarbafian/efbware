//
//  SettingsViewController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit
import PDFKit

class SettingsViewController: UIViewController {

    private let LOGGER = Logger.getInstance()
    
    var pdfViewEx: PDFView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LOGGER.debug(msg: "SettingsViewController.viewDidLoad")
        
        pdfViewEx = PDFView(frame: self.pdfView.bounds)
        pdfViewEx.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.pdfView.addSubview(pdfViewEx)
        
        // Fit content in PDFView.
        pdfViewEx.autoScales = true
        
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
        
        // query
        let documents = DatabaseService.getInstance().listAllDocuments()
        for doc in documents {
            LOGGER.debug(msg: "found document, id=\(doc.id), label=\(doc.label), fileName=\(doc.fileName) docId=\(doc.docId), fileRef=\(doc.fileRef), parts=\(doc.parts), status=\(doc.status)")
            LOGGER.debug(msg: "_")
            
            let parts = DatabaseService.getInstance().listDocumentParts(documentId: doc.id, status: DocumentPartStatus.NEW)
            for part in parts {
                LOGGER.debug(msg: "  found part, id=\(part.id), documentId=\(part.documentId), partNumber=\(part.partNumber), status=\(part.status)")
            }
            LOGGER.debug(msg: "___")
        }
        
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
    
    @IBAction func listDocsButton(_ sender: UIButton) {
        
        print("PRESSED PARTS")
        
        let userURL = FileSystemService.getInstance().getDocumentsUrl()
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: userURL, includingPropertiesForKeys: nil)
            
            for file in fileURLs {
                
                let attributes = try FileManager.default.attributesOfItem(atPath: file.path)
                let size = attributes[FileAttributeKey.size] as! Int
                
                print("Found file: \(file.path)")
                print("file size: \(String(size))")
                
                var isDir : ObjCBool = false
                FileManager.default.fileExists(atPath: file.path, isDirectory: &isDir)
                
                if isDir.boolValue {
                    do {
                        let partsURLs = try FileManager.default.contentsOfDirectory(at: file, includingPropertiesForKeys: nil)
                        
                        for part in partsURLs {
                            
                            let attributes2 = try FileManager.default.attributesOfItem(atPath: part.path)
                            let size = attributes2[FileAttributeKey.size] as! Int
                            
                            print("   Found file: \(part.path)")
                            print("   file size: \(String(size))")
                            
                        }
                    }
                }
            }
            
        } catch {
            print("Error while enumerating files \(userURL.path): \(error.localizedDescription)")
        }
    }
    @IBAction func deleteDocumentsButton(_ sender: UIButton) {
        
        print("PRESSED DELETE DOCS")
        
        let userURL = FileSystemService.getInstance().getDocumentsUrl()
        
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
            }
            
        } catch {
            print("Error while enumerating files \(userURL.path): \(error.localizedDescription)")
        }
    }
    @IBAction func manualFinishButton(_ sender: UIButton) {
        
        print("PRESSED M")
        
        let bd = DatabaseService.getInstance().listDocumentsByStatus(status: DocumentStatus.BUILDING)
        
        if bd.count > 0 {
            
            let d = bd[0]
            
            print("Test doc is: \(d.fileName)")
            
            let docSorter: (DocumentPartData, DocumentPartData) -> Bool = {
                
                return $0.partNumber < $1.partNumber
            }
            
            let docParts = DatabaseService.getInstance().listDocumentParts(documentId: d.id, status: DocumentPartStatus.DONE).sorted(by: docSorter)
            
            for td in docParts {
                print("partNumber: \(td.partNumber)")
            }
            
            print("Parts found: \(docParts.count)")
            
            let docKey = KeyUtils.buildDocumentKey(doc: d)
            
            var partsUrl: Array<URL> = []
            
            let fileSystemService = FileSystemService.getInstance()
            
            for part in docParts {
                
                let partKey = KeyUtils.buildDocumentPartKey(doc: d, part: part)
                let partUrl = fileSystemService.getDocumentsUrl().appendingPathComponent(docKey).appendingPathComponent(partKey)
                partsUrl.append(partUrl)
            }
            
            let documentUrl = fileSystemService.getDocumentsUrl().appendingPathComponent(d.fileName)
            
            LOGGER.info(msg: "Document output path: \(documentUrl.path)")
            
            do {
                
                if fileSystemService.existFile(file: documentUrl.path) {
                    LOGGER.info(msg: "❓ Document already exists, deleting it")
                    try fileSystemService.delete(url: documentUrl)
                    LOGGER.info(msg: "Document deleted")
                }
                else {
                    LOGGER.info(msg: "Document does not exist")
                }
                
                do {
                    
                    //let fileHandle = FileHandle(forWritingAtPath: documentUrl.path)
                    //LOGGER.debug(msg: "💚 File handle acquired")
                    
                    let urlZero = partsUrl[0]
                    
                    var fullData: Data = try Data(contentsOf: urlZero)
                    
                    for partNum in 1..<partsUrl.count {
                    
                        let partData = try Data(contentsOf: partsUrl[partNum])
                        fullData.append(partData)
                        
                        //fileHandle.seekToEndOfFile()
                        //fileHandle.write(partData)
                        
                        let options: NSData.WritingOptions = []
                        
                        try fullData.write(to: documentUrl, options: options)
                        
                        LOGGER.debug(msg: "All data written to: \(documentUrl.path)")
                        
                    }
                    //fileHandle.closeFile()
                    //LOGGER.debug(msg: "File handle closed")
                    
                    print("Show in PDFView")
                    let attributes = try FileManager.default.attributesOfItem(atPath: documentUrl.path)
                    let size = attributes[FileAttributeKey.size] as! Int
                    print("File size is: \(size)")
                    
                    pdfViewEx!.document = PDFDocument(url: documentUrl)
                } catch {
                    LOGGER.error(msg: "⛔ Could not write to file: \(error.localizedDescription)")
                    //LOGGER.error(msg: "⛔ Could not acquire file handle: \(error.localizedDescription)")
                }
            }
            catch {
                print("ERROR ERROR ERROR")
            }
        }
    }
    
    @IBOutlet weak var pdfView: UIView!
}
