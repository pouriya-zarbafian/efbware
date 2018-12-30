//
//  HttpService.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class HttpService: NSObject {
    
    private let LOGGER = Logger.getInstance()

    func post(url: String, xml: String, onSuccess: @escaping (HTTPURLResponse, Data) -> (Void), onError: @escaping () -> (Void)) {
        
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.setValue(Constants.HTTP_CONTENT_TYPE_XML, forHTTPHeaderField: "Content-Type")
        request.setValue(LoginController.sid, forHTTPHeaderField: Constants.HEADER_SESSION_ID)
        
        request.httpMethod = "POST"
        
        self.LOGGER.trace(msg: "host=\(String(describing: request.url?.host))")
        
        request.httpBody = xml.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                self.LOGGER.error(msg: "error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                self.LOGGER.error(msg: "statusCode should be 200, but is \(httpStatus.statusCode)")
                self.LOGGER.error(msg: "response = \(String(describing: response))")
                
                onError()
                
                return
            }
            
            let httpResponse = response as? HTTPURLResponse
            
            onSuccess(httpResponse!, data)
            
        }
        task.resume()
    }
}
