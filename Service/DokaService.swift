//
//  DokaService.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class DokaService: NSObject {

    private let LOGGER = Logger.getInstance()
    
    var sid: String
    
    var httpService = HttpService()
    
    init(sid: String) {
        self.sid = sid
    }
    
    func getDocuments(onResult: @escaping (Array<DocumentData>) -> (Void)) {
        
        let docReq = DocumentRequest()
        
        let xml = docReq.toXml()
        
        LOGGER.debug(msg: "XML\n\(xml)")
        
        let successClosure: (HTTPURLResponse, Data) -> Void = {
 
            let xml = String(data: $1, encoding: .utf8)!
            
            self.LOGGER.info(msg: "documents retrieved, xml=\n\(xml)")
            
            let docs = XmlUtils.parseSearchResult(xml: xml)
            
            onResult(docs)
        }
        
        let errorClosure: () -> Void = {
            
            self.LOGGER.error(msg: "error while retrieving documents")
        }
        
        httpService.post(url: Constants.URL_ITEM_SEARCH , xml: xml, onSuccess: successClosure, onError: errorClosure)
    }
}
