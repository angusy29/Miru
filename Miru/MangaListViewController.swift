//
//  MangaListViewController.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import UIKit
import Foundation

class MangaListViewController: UIViewController {
    var currentlyReading: [Manga]?
    var completed: [Manga]?
    var onHold: [Manga]?
    var dropped: [Manga]?
    var planToRead: [Manga]?
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Manga list"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("MANGA LIST LOAD")
        
        getAnimeList()
    }
    
    func getAnimeList() {
        guard let username = MiruGlobals.username else { return }
        let url = URL(string: "https://myanimelist.net/malappinfo.php?u=" + username + "&status=all&type=manga")
        
        let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
