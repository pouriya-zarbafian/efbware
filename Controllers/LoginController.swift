//
//  LoginController.swift
//  efbware
//
//  Created by Pouriya Zarbafian on 24/12/2018.
//  Copyright © 2018 com.zarbafian. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

    private let LOGGER = Logger.getInstance()
    
    //private let dokaXml = DokaXml()
    
    static var sid = ""
    
    var httpService = HttpService()
    
    var fileSystemService = FileSystemService.getInstance()
    
    // MARK: Init
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let sid = FileSystemService.getInstance().readSid()
        
        if sid.isEmpty {
            // No sid
        }
        else {
            // Attempt login with sid
            let errorClosure: () -> Void = {
                // Sid was invalid
                self.LOGGER.debug(msg: "Could not login from sid")
                LoginController.sid = ""
            }
            let successClosure: (HTTPURLResponse, String) -> Void = {
                // Sid was valid
                self.LOGGER.debug(msg: "Logged in from sid")
                let sid = $0.allHeaderFields[Constants.HEADER_SESSION_ID] as! String
                _ = $1
                self.receivedValidSid(sid: sid)
            }
            
            // TODO: improve this
            LoginController.sid = sid
            
            httpService.post(url: Constants.URL_INFO, xml: "", onSuccess: successClosure, onError: errorClosure)
        }
    }
    
    // MARK: UI
    @IBOutlet weak var loginInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    @IBAction func loginButton(_ sender: UIButton) {
        
        LOGGER.info(msg: "loginButton")
        
        let customer = "pouriya"
        
        if let login = loginInput.text, let pass = passwordInput.text {
        
            let loginData = LoginData(customerName: customer, user: login, password: pass)
            
            //let xml = dokaXml.loginRequest(loginData: loginData)
            let xml = LoginRequest.toXml(loginData: loginData)
            print("XML\n\(xml)")
            
            let successClosure: (HTTPURLResponse, String) -> Void = {
                let sid = $0.allHeaderFields[Constants.HEADER_SESSION_ID] as! String
                _ = $1
                self.LOGGER.info(msg: "Login successful, sid=\(sid)")
                self.receivedValidSid(sid: sid)
                
                // write sid to cache
                FileSystemService.getInstance().writeSid(sid: sid)
            }
            
            let errorClosure: () -> Void = {
                
                let alert = UIAlertController(title: "Login Error", message: "Login or username is incorrect", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
            
            httpService.post(url: Constants.URL_LOGIN, xml: xml, onSuccess: successClosure, onError: errorClosure)
        }
    }
    
    private func receivedValidSid(sid: String) {
        LoginController.sid = sid
        RootController.loggedIn = true
        DispatchQueue.main.async {
            self.dismiss(animated: false, completion: nil)
        }
    }
}
