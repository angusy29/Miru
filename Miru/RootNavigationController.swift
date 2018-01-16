//
//  RootNavigationController.swift
//  Miru
//
//  Created by Angus Yuen on 28/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

/*
 * RootNavigationController is the root controller of all viewcontrollers
 * Contains the user
 */
class RootNavigationController: UINavigationController {
    var user: User?
    var didChange = false
    var imageCache = NSCache<NSString, UIImage>()       // map of image links to the actual image
    var mediaDetailsCache = NSCache<NSString, MediaDetails>()   // map of "anime|manga"+id to synopsis
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
    }
    
    @objc func logout(sender: AnyObject) {
        UserDefaults.standard.set(false, forKey: "miruIsLoggedIn")
        self.performSegue(withIdentifier: "UnwindToLoginViewController", sender: self)
    }
}
