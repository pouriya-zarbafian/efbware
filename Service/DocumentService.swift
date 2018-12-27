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
    
    private var httpService = HttpService()
    
    func handleNewDocument(document: DocumentData) {
        
        LOGGER.debug(msg: "handleNewDocument, id=\(document.id)")
        
        let doc = DatabaseService.getInstance().findDocumentById(id: document.id)
        
        if doc == nil {
            LOGGER.debug(msg: "document not found, id=\(document.id)")
        }
        else {
            LOGGER.debug(msg: "document found, id=\(document.id)")
            
            for partNumber in 0..<document.parts {
                let part = DocumentPartData(partNumber: partNumber, documentId: document.id)
                _ = DatabaseService.getInstance().insertDocumentPart(part: part)
            }
            
            doc!.status = DocumentStatus.BUILDING
            
            _ = DatabaseService.getInstance().updateDocument(document: doc!)
        }
    }
    
    func handleBuildingDocument(document: DocumentData) {
        
        LOGGER.debug(msg: "handleBuildingDocument, id=\(document.id)")
        
        let doc = DatabaseService.getInstance().findDocumentById(id: document.id)
        
        if doc == nil {
            LOGGER.debug(msg: "document not found, id=\(document.id)")
        }
        else {
            LOGGER.debug(msg: "document found, id=\(document.id)")
            
            let docParts = DatabaseService.getInstance().listDocumentParts(documentId: doc!.id, status: DocumentPartStatus.NEW)
            
            LOGGER.debug(msg: "document \(doc!.id), \(docParts.count) parts found")
            
            for part in docParts {
                
                downloadPart(document: doc!, part: part)
                //_ = DatabaseService.getInstance().insertDocumentPart(part: part)
            }
        }
    }
    
    func checkBuildingDocument(document: DocumentData) {
        
        LOGGER.debug(msg: "checkBuildingDocument, id=\(document.id)")
        
        let doc = DatabaseService.getInstance().findDocumentById(id: document.id)
        
        if doc == nil {
            LOGGER.debug(msg: "document not found, id=\(document.id)")
        }
        else {
            LOGGER.debug(msg: "document found, id=\(document.id)")
            
            let docParts = DatabaseService.getInstance().listDocumentParts(documentId: doc!.id, status: DocumentPartStatus.DONE).sorted(by: Constants.CLOSURE_SORT_DOCUMENT_PARTS)
            
            LOGGER.debug(msg: "document \(doc!.id), parts \(docParts.count) / \(document.parts)")
            
            if docParts.count == document.parts {
                
                LOGGER.info(msg: "🌀 Finalize document \(document.id)")
                
                
                let docKey = KeyUtils.buildDocumentKey(doc: document)
                
                var partsUrl: Array<URL> = []
                
                for part in docParts {
                    
                    let partKey = KeyUtils.buildDocumentPartKey(doc: document, part: part)
                    let partUrl = fileSystemService.getDocumentsUrl().appendingPathComponent(docKey).appendingPathComponent(partKey)
                    partsUrl.append(partUrl)
                }
                
                let documentUrl = fileSystemService.getDocumentsUrl().appendingPathComponent(document.fileName)
                
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
                        let urlZero = partsUrl[0]
                        
                        var fullData: Data = try Data(contentsOf: urlZero)
                        
                        for partNum in 1..<partsUrl.count {
                            
                            let partData = try Data(contentsOf: partsUrl[partNum])
                            fullData.append(partData)
                        }
                        
                        try fullData.write(to: documentUrl)
                        
                        LOGGER.debug(msg: "💚 All data written to: \(documentUrl.path)")

                    } catch {
                        LOGGER.error(msg: "⛔ Could not acquire file handle: \(error.localizedDescription)")
                        throw FileSystemError.cannotAcquireHandle(message: "Could not acquire file handle")
                    }
                    
                    
                    LOGGER.info(msg: "📄 Document is complete: \(documentUrl.path)")
                    
                    document.status = DocumentStatus.COMPLETE
                    
                    _ = DatabaseService.getInstance().updateDocument(document: document)
                    
                    LOGGER.info(msg: "📄📄 Database was updated")
                    
                } catch {
                    LOGGER.error(msg: "Error writing to file: \(documentUrl.path)")
                    // TODO
                    return
                }
                
                let partFolderUrl = fileSystemService.getDocumentsUrl().appendingPathComponent(docKey)
                
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
                let docKey = KeyUtils.buildDocumentKey(doc: document)
                let partKey = KeyUtils.buildDocumentPartKey(doc: document, part: part)
                
                let partFolderUrl = FileSystemService.getInstance().getDocumentsUrl().appendingPathComponent(docKey)
                
                if self.fileSystemService.existDir(dir: partFolderUrl.path) {
                    self.LOGGER.info(msg: "Part folder found: \(partFolderUrl.path)")
                }
                else{
                    try self.fileSystemService.createDir(dir: partFolderUrl)
                    self.LOGGER.info(msg: "Part folder created: \(partFolderUrl.path)")
                }
                
                let partUrl = FileSystemService.getInstance().getDocumentsUrl().appendingPathComponent(docKey).appendingPathComponent(partKey)
                
                try data.write(to: partUrl, options: [])
                
                self.LOGGER.info(msg: "🎈 Part written to file")
                
                part.status = DocumentPartStatus.DONE
                
                _ = DatabaseService.getInstance().updateDocumentPart(part: part)
                
                self.LOGGER.info(msg: "🎈🎈 Part status updated")
            }
            catch {
                print("Error writing to file part \(part.partNumber) of document \(document.id)")
            }
        }
        
        let partReq = DocumentPartRequest(document: document, part: part)
        
        let xml = partReq.toXml()

        LOGGER.debug(msg: "XML\n\(xml)")
        
        self.httpService.post(url: Constants.URL_READ_PART, xml: xml, onSuccess: successClosure, onError: errorClosure)
    }
}
