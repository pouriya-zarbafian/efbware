//
//  DocumentService.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 26/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DocumentService: NSObject {

    private let LOGGER = Logger.getInstance()
    
    private var fileSystemService = FileSystemService.getInstance()
    
    private var databaseService = DatabaseService.getInstance()
    
    private var httpService = HttpService()
    
    func handleNewDocument(document: DocumentData) {
        
        LOGGER.debug(msg: "handleNewDocument, id=\(document.id)")
        
        if let doc = databaseService.findDocumentById(id: document.id) {
        
            LOGGER.debug(msg: "document found, id=\(document.id)")
        
            do {
                // create document directory
                let docFolder = fileSystemService.getDocumentFolder(document: document)
                try fileSystemService.createDir(dir: docFolder)
                
                // init parts in database
                for partNumber in 0..<document.parts {
                    let part = DocumentPartData(partNumber: partNumber, documentId: document.id)
                    _ = databaseService.insertDocumentPart(part: part)
                }
                
                doc.status = DocumentStatus.BUILDING
                
                _ = databaseService.updateDocument(document: doc)
            } catch {
                LOGGER.error(msg: "Error while processing new document: \(doc.docId)")
            }
        
        }
        else {
            LOGGER.debug(msg: "document not found, id=\(document.id)")
        }
    }
    
    func handleBuildingDocument(document: DocumentData) {
        
        LOGGER.debug(msg: "handleBuildingDocument, id=\(document.id)")
        
        let doc = databaseService.findDocumentById(id: document.id)
        
        if doc == nil {
            LOGGER.debug(msg: "document not found, id=\(document.id)")
        }
        else {
            LOGGER.debug(msg: "document found, id=\(document.id)")
            
            let docParts = databaseService.listDocumentParts(documentId: doc!.id, status: DocumentPartStatus.NEW)
            
            LOGGER.debug(msg: "document \(doc!.id), \(docParts.count) parts found")
            
            for part in docParts {
                
                downloadPart(document: doc!, part: part)
            }
        }
    }
    
    func checkBuildingDocument(document: DocumentData) {
        
        LOGGER.debug(msg: "checkBuildingDocument, id=\(document.id)")
        
        let doc = databaseService.findDocumentById(id: document.id)
        
        if doc == nil {
            LOGGER.debug(msg: "document not found, id=\(document.id)")
        }
        else {
            LOGGER.debug(msg: "document found, id=\(document.id)")
            
            let docParts = databaseService.listDocumentParts(documentId: doc!.id, status: DocumentPartStatus.DONE).sorted(by: Constants.CLOSURE_SORT_DOCUMENT_PARTS)
            
            LOGGER.debug(msg: "document \(doc!.id), parts \(docParts.count) / \(document.parts)")
            
            if docParts.count == document.parts {
                
                LOGGER.info(msg: "🌀 Finalize document \(document.id)")
                
                var partsUrl: Array<URL> = []
                
                for part in docParts {
                    
                    let partFilename = fileSystemService.getPartFilename(part: part)
                    let partUrl = fileSystemService.getDocumentPartsFolder(document: document).appendingPathComponent(partFilename)
                    
                    partsUrl.append(partUrl)
                }
                
                let documentUrl = fileSystemService.getDocumentUrl(document: document)
                
                LOGGER.info(msg: "Document output path: \(documentUrl.path)")
                
                do {
                    
                    if fileSystemService.existFile(file: documentUrl.path) {
                        LOGGER.info(msg: "❓ Document already exists, deleting it")
                        try fileSystemService.delete(url: documentUrl)
                        LOGGER.info(msg: "Document deleted")
                    }
                    else {
                        LOGGER.debug(msg: "Document does not exist")
                    }
                    
                    do {
                        let urlZero = partsUrl[0]
                        
                        var fullData: Data = try Data(contentsOf: urlZero)
                        
                        for partNum in 1..<partsUrl.count {
                            
                            let partData = try Data(contentsOf: partsUrl[partNum])
                            fullData.append(partData)
                        }
                        
                        try fullData.write(to: documentUrl)
                        
                        LOGGER.debug(msg: "💚 All data written to: \(documentUrl.path)")

                    } catch {
                        LOGGER.error(msg: "⛔ Error while writing the parts of the document: \(error.localizedDescription)")
                        throw FileSystemError.fileCreationError(message: "Error while writing the parts of the document")
                    }
                    
                    LOGGER.info(msg: "📄 Document is complete: \(documentUrl.path)")
                    
                    document.status = DocumentStatus.COMPLETE
                    
                    _ = databaseService.updateDocument(document: document)
                    
                    LOGGER.info(msg: "📄📄 Database was updated")
                    
                } catch {
                    LOGGER.error(msg: "Error writing to file: \(documentUrl.path)")
                    // TODO
                    return
                }
                
                let partFolderUrl = fileSystemService.getDocumentPartsFolder(document: document)
                
                do {
                    LOGGER.info(msg: "💙 Deleting parts folder")
                    
                    try fileSystemService.delete(url: partFolderUrl)
                    
                    LOGGER.info(msg: "💙💙 Parts folder deleted")
                }
                catch {
                    LOGGER.error(msg: "Error deleting parts folder: \(partFolderUrl.path)")
                }
            }
        }
    }
    
    private func downloadPart(document: DocumentData, part: DocumentPartData) {
        
        let errorClosure: () -> Void = {
            
            print("error downloading part \(part.partNumber) of document \(document.id)")
        }
        let successClosure: (HTTPURLResponse, Data) -> Void = {
            
            print("success downloading part \(part.partNumber) of document \(document.id)")
            
            _ = $0
            let data = $1
            
            do {
                
                let partFolderUrl = self.fileSystemService.getDocumentPartsFolder(document: document)
                
                if self.fileSystemService.existDir(dir: partFolderUrl.path) {
                    self.LOGGER.info(msg: "Part folder found: \(partFolderUrl.path)")
                }
                else{
                    try self.fileSystemService.createDir(dir: partFolderUrl)
                    self.LOGGER.info(msg: "Part folder created: \(partFolderUrl.path)")
                }
                
                let partFilename = self.fileSystemService.getPartFilename(part: part)
                let partUrl = self.fileSystemService.getDocumentPartsFolder(document: document).appendingPathComponent(partFilename)
                
                try data.write(to: partUrl, options: [])
                
                self.LOGGER.info(msg: "🎈 Part written to file")
                
                part.status = DocumentPartStatus.DONE
                
                _ = self.databaseService.updateDocumentPart(part: part)
                
                self.LOGGER.info(msg: "🎈🎈 Part status updated")
            }
            catch {
                print("Error writing to file part \(part.partNumber) of document \(document.id)")
            }
        }
        
        let partReq = DocumentPartRequest(document: document, part: part)
        
        let xml = partReq.toXml()

        LOGGER.trace(msg: "XML\n\(xml)")
        
        self.httpService.post(url: Constants.URL_READ_PART, xml: xml, onSuccess: successClosure, onError: errorClosure)
    }
}
