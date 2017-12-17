//
//  BrowseViewController.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import UIKit
import Foundation

class BrowseViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    var animeSearchResults = [Anime]()
    var mangaSearchResults = [Manga]()
    
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Browse"
        
        // place search controller in navigation bar
        self.navigationController?.navigationBar.topItem?.searchController = searchController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
 
        // set up search controller
        searchController.searchResultsUpdater = self
        searchController.searchBar.scopeButtonTitles = ["Anime", "Manga"]
        searchController.searchBar.delegate = self
        searchController.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.tintColor = UIColor.white
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // print("Update")
        // do nothing
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = self.searchController.searchBar.text else { return }
        if searchController.searchBar.selectedScopeButtonIndex == MiruGlobals.ANIME {
            // search for anime
            malkit.searchAnime(searchText, completionHandler: { (items, status, err) in
                //result is Data(XML). You need to parse XML.
                //status is HTTPURLResponse
                //your process
                if (status?.statusCode == 200) {
                    print(NSString(data: items!, encoding: String.Encoding.utf8.rawValue))
                }
            })
        } else if searchController.searchBar.selectedScopeButtonIndex == MiruGlobals.MANGA {
            // search for manga
            malkit.searchManga("naruto", completionHandler: { (items, status, err) in
                //result is Data(XML). You need to parse XML.
                //status is HTTPURLResponse
                //your process
                if (status?.statusCode == 200) {
                    print(NSString(data: items!, encoding: String.Encoding.utf8.rawValue))
                }
            })
        }
        
        searchController.searchBar.resignFirstResponder()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
