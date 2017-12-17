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
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var cache = NSCache<NSString, UIImage>()
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationController?.navigationBar.topItem?.title = "Profile"
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("PROFILE LIST LOAD")
        
        userNameLabel.text = MiruGlobals.user.user_name
        profileImageView.image = nil
        
        // checks the cache, and downloads the image or uses the one in the cache
        let img = cache.object(forKey: MiruGlobals.user.user_picture! as NSString)
        setProfileImage(image: img)
    }
    
    func setProfileImage(image: UIImage?) {
        if image != nil{
            //The image exist so you assign it to your UIImageView
            self.profileImageView.image = image
        } else {
            //Create the request to download the image
            let url = URL(string: MiruGlobals.user.user_picture!)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data!)
                    self.cache.setObject(self.profileImageView.image!, forKey: MiruGlobals.user.user_picture! as NSString)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
