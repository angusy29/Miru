//
//  LoginViewController.swift
//  Miru
//
//  Created by Angus Yuen on 13/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import MalKit
import UIKit
import SwiftKeychainWrapper

let malkit = MalKit()

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameInput: UITextField!
    @IBOutlet weak var passwordInput: UITextField!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.bool(forKey: "miruIsLoggedIn") {
            guard let retrieveUsername = KeychainWrapper.standard.string(forKey: "malUser") else { return }
            guard let retrievePassword = KeychainWrapper.standard.string(forKey: "malPass") else { return }
            usernameInput.text = retrieveUsername
            passwordInput.text = retrievePassword
            loginAuthenticate()
        }
    }
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

        let _ = KeychainWrapper.standard.set(username, forKey: "miruUser")
        let _ = KeychainWrapper.standard.set(password, forKey: "miruPass")
        
        malkit.setUserData(userId: username, passwd: password)
        malkit.verifyCredentials(completionHandler: { (result, status, err) in
            if (status?.statusCode == 200) {
                UserDefaults.standard.set(true, forKey: "miruIsLoggedIn")
                DispatchQueue.main.sync(execute: {
                    self.performSegue(withIdentifier: "LoginSuccess", sender: nil)
                })
            } else {
                Util.dismissLoading(vc: self)
                print("LOGIN FAIL")
            }
        })
    }
    
    /*
     * Before perform segue to RootNavigationController, we set the user
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let username = usernameInput.text else { return }
        
        // Create a variable that you want to send
        let user = User(name: username)
        
        // Create a new variable to store the instance of PlayerTableViewController
        let destVC = segue.destination as! RootNavigationController
        destVC.user = user
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
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

