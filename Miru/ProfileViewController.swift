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
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Profile"
        // self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("PROFILE LIST LOAD")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
