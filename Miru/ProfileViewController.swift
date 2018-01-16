//
//  Profile.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

class ProfileViewController: UIViewController {    

    var rootNavigationController: RootNavigationController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Profile"
        // self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("PROFILE LIST LOAD")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.rootNavigationController = self.navigationController as? RootNavigationController
        let destVC = segue.destination as? UserStatisticsTableView
        destVC?.user = self.rootNavigationController?.user
    }
    
    @objc func logout(sender: AnyObject) {
        UserDefaults.standard.set(false, forKey: "miruIsLoggedIn")
        self.performSegue(withIdentifier: "LogoutSuccess", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
