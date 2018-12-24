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
            
            attemptLogin(url: Constants.URL_LOGIN, xml: xml)
        }
        /*
        
        
        let httpClient = HttpClient()
        httpClient.sendResult(url: HttpClient.LOGIN_URL, xml: xml)
        //httpClient.sendResult(url: HttpClient.LOGOUT_URL, xml: "")
         */
    }
    
    // MARK: Methods
    func attemptLogin(url: String, xml: String) {
        
        let url = URL(string: url)!
        var request = URLRequest(url: url)
        request.setValue("application/xml", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        
        print("host=\(request.url?.host)")
        
        request.httpBody = xml.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                
                // create the alert
                let alert = UIAlertController(title: "Login Error", message: "Login or username is incorrect", preferredStyle: UIAlertController.Style.alert)
                
                // add an action (button)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                
                // show the alert
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            let httpResponse = response as? HTTPURLResponse
            let sid = httpResponse?.allHeaderFields["app-session-id"] as! String
            
            LoginController.sid = sid
            print("Login successful, sid=\(sid)")
            
            RootController.loggedIn = true
            
            DispatchQueue.main.async {
                self.dismiss(animated: false, completion: nil)
            }
            
        }
        task.resume()
        
        // TODO: return task
    }
}
