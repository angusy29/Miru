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

