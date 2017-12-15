//
//  LoginViewController.swift
//  Miru
//
//  Created by Angus Yuen on 13/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import MalKit
import UIKit

let malkit = MalKit()

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // getAnimeList()
        usernameInput.setBottomBorder()
        passwordInput.setBottomBorder()
    }
    
    @IBAction func loginAuthenticate() {
        // guard let url = URL(string: "https://myanimelist.net/api/account/verify_credentials.xml") else { return }
        
        guard let username = usernameInput.text else { return }
        guard let password = passwordInput.text else { return }
        
        /*let loginString = String(format: "%@:%@", username, password)
        let base64LoginString = loginString.data(using: .utf8)?.base64EncodedString()
        // let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())

        var request = URLRequest(url: url)
        request.setValue(base64LoginString, forHTTPHeaderField: "Authorization")
        
        /*let protectionSpace = URLProtectionSpace.init(host: "myanimelist.net",
                                                      port: 80,
                                                      protocol: "http",
                                                      realm: nil,
                                                      authenticationMethod: nil)
        
        let userCredential = URLCredential(user: username,
                                           password: password,
                                           persistence: .permanent)
        
        URLCredentialStorage.shared.setDefaultCredential(userCredential, for: protectionSpace)*/
        
        print(loginString)
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
            // if error we show that login is incorrect
            // if no error then we transition to the next view controller
            print("RESPONSE")
            print(response)
            print("DATA")
            print(data)
            print("ERROR")
            print(error)
            
            print("DATA STRING")
            let dataString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            print(dataString)
        }.resume()*/
        
        malkit.setUserData(userId: username, passwd: password)
        malkit.verifyCredentials(completionHandler: { (result, status, err) in
            if (status?.statusCode == 200) {
                MiruGlobals.username = username
                DispatchQueue.main.async(execute: {
                    self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
                })
            } else {
                print("LOGIN FAIL")
            }
        })
    }
    
    // update anime via
    // curl -i -u Gashrei:password -d data="<entry><status>1</status><episode>3</episode></entry>" https://myanimelist.net/api/animelist/add/21.xml

    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

