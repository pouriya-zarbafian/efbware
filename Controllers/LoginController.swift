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
                LoginController.sid = sid
                RootController.loggedIn = true
                DispatchQueue.main.async {
                    self.dismiss(animated: false, completion: nil)
                }
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
}
