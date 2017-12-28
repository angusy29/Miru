//
//  BrowseViewController.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import UIKit
import Foundation

class BrowseViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    var animeSearchResults = [Anime]()
    var mangaSearchResults = [Manga]()
    
    @IBOutlet weak var searchResultTableView: UITableView!
    
    let searchController = UISearchController(searchResultsController: nil)

    // XML parsing attributes
    var currentXMLElement: String?
    var currentAnimeObj: Anime?
    var currentMangaObj: Manga?
    
    var imageCache = NSCache<NSString, UIImage>()
    var searchType: Int?        // MiruGlobal.ANIME or MiruGlobals.MANGA
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Browse"
        
        // place search controller in navigation bar
        self.navigationController?.navigationBar.topItem?.searchController = searchController
        self.navigationController?.navigationBar.topItem?.hidesSearchBarWhenScrolling = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.topItem?.searchController = nil
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
        
        self.searchResultTableView.register(UINib(nibName: "TableViewSeriesCell", bundle: nil), forCellReuseIdentifier: "TableViewSeriesCell")
        self.searchResultTableView.delegate = self
        self.searchResultTableView.dataSource = self
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // print("Update")
        // do nothing
        
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = self.searchController.searchBar.text else { return }
        if (searchText.count < 3) {
            // need to let user know to input more than 3 chars
            return
        }
        
        searchType = self.searchController.searchBar.selectedScopeButtonIndex
        if searchController.searchBar.selectedScopeButtonIndex == MiruGlobals.ANIME {
            let sem = DispatchSemaphore(value: 0)
            // search for anime
            malkit.searchAnime(searchText, completionHandler: { (items, status, err) in
                //result is Data(XML). You need to parse XML.
                //status is HTTPURLResponse
                //your process
                if (status?.statusCode == 200) {
                    self.animeSearchResults.removeAll()

                    print(NSString(data: items!, encoding: String.Encoding.utf8.rawValue))
                    if let data = items {
                        let parser = XMLParser(data: data)
                        parser.delegate = self
                        parser.parse()
                        sem.signal()
                    }
                }
            })
            sem.wait()
            self.searchResultTableView.reloadData()

        } else if searchController.searchBar.selectedScopeButtonIndex == MiruGlobals.MANGA {
            // search for manga
            let sem = DispatchSemaphore(value: 0)

            malkit.searchManga(searchText, completionHandler: { (items, status, err) in
                //result is Data(XML). You need to parse XML.
                //status is HTTPURLResponse
                //your process
                if (status?.statusCode == 200) {
                    self.mangaSearchResults.removeAll()

                    print(NSString(data: items!, encoding: String.Encoding.utf8.rawValue))
                    if let data = items {
                        let parser = XMLParser(data: data)
                        parser.delegate = self
                        parser.parse()
                        sem.signal()
                    }
                }
            })
            sem.wait()
            
            self.searchResultTableView.reloadData()
        }
        searchController.searchBar.resignFirstResponder()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if (elementName == "entry") {
            // create depending on which one we want
            if searchType == MiruGlobals.ANIME {
                currentAnimeObj = Anime()
            } else {
                currentMangaObj = Manga()
            }
        }
        currentXMLElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (currentXMLElement == "id") {
            if searchType == MiruGlobals.ANIME {
                currentAnimeObj?.series_animedb_id = Int(string)
            } else {
                currentMangaObj?.series_mangadb_id = Int(string)
            }
        } else if (currentXMLElement == "title") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.series_title = currentAnimeObj?.series_title == nil ? string : (currentAnimeObj?.series_title)! + string
            } else {
                currentMangaObj?.series_title = currentMangaObj?.series_title == nil ? string : (currentMangaObj?.series_title)! + string
            }
        } else if (currentXMLElement == "english") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.english = currentAnimeObj?.english == nil ? string : (currentAnimeObj?.english)! + string
            } else {
                currentMangaObj?.series_title = currentMangaObj?.series_title == nil ? string : (currentMangaObj?.series_title)! + string
            }
        } else if (currentXMLElement == "synonyms") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.series_synonyms?.append(string)
            } else {
                currentMangaObj?.series_synonyms?.append(string)
            }
        } else if (currentXMLElement == "episodes") {
            currentAnimeObj?.series_episodes = Int(string)
        } else if (currentXMLElement == "chapters") {
            currentMangaObj?.series_chapters = Int(string)
        } else if (currentXMLElement == "volumes") {
            currentMangaObj?.series_volumes = Int(string)
        } else if (currentXMLElement == "score") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.mal_score = Double(string)
            } else {
                currentMangaObj?.mal_score = Double(string)
            }
        } else if (currentXMLElement == "type") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.search_result_type = string
            } else {
                currentAnimeObj?.search_result_status = string
            }
        } else if (currentXMLElement == "status") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.search_result_status = string
            } else {
                currentMangaObj?.search_result_status = string
            }
        } else if (currentXMLElement == "start_date") {
            
        } else if (currentXMLElement == "end_date") {
            
        } else if (currentXMLElement == "synopsis") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.synopsis = currentAnimeObj?.synopsis == nil ? string : (currentAnimeObj?.synopsis)! + string
            } else {
                currentMangaObj?.synopsis = currentMangaObj?.synopsis == nil ? string : (currentMangaObj?.synopsis)! + string
            }
        } else if (currentXMLElement == "image") {
            if (searchType == MiruGlobals.ANIME) {
                currentAnimeObj?.series_image = string
            } else {
                currentMangaObj?.series_image = string
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "entry") {
            if searchType == MiruGlobals.ANIME {
                guard let animeObj = currentAnimeObj else { return }
                animeSearchResults.append(animeObj)
                currentAnimeObj = nil
            } else {
                guard let mangaObj = currentMangaObj else { return }
                mangaSearchResults.append(mangaObj)
                currentMangaObj = nil
            }
        }
        
        currentXMLElement = nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchType == MiruGlobals.ANIME {
            return animeSearchResults.count
        } else {
            return mangaSearchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = self.searchResultTableView.dequeueReusableCell(withIdentifier: "TableViewSeriesCell") as! TableViewSeriesCell
        
        if (searchType == MiruGlobals.ANIME) {
            cell.title.text = animeSearchResults[indexPath.row].series_title
            cell.airingStatus.text = animeSearchResults[indexPath.row].search_result_status
            cell.numCompleted.setTitle(String(describing: animeSearchResults[indexPath.row].series_episodes!) + " episodes", for: UIControlState.normal)

            cell.MALMyScoreLabel.text = "MAL Score"
            if let malScore = animeSearchResults[indexPath.row].mal_score {
                cell.myScore.setTitle(String(describing: malScore), for: UIControlState.normal)
            }
            cell.imageThumbnail.image = nil
            
            // checks the cache, and downloads the image or uses the one in the cache
            let img = imageCache.object(forKey: animeSearchResults[indexPath.row].series_image! as NSString)
            cell.configureCell(anime: animeSearchResults[indexPath.row], image: img, cache: imageCache)
        } else {
            cell.title.text = mangaSearchResults[indexPath.row].series_title
            cell.airingStatus.text = mangaSearchResults[indexPath.row].search_result_status
            cell.numCompleted.setTitle(String(describing: mangaSearchResults[indexPath.row].series_chapters!) + " chapters", for: UIControlState.normal)
            
            cell.MALMyScoreLabel.text = "MAL Score"
           
            if let malScore = mangaSearchResults[indexPath.row].mal_score {
                cell.myScore.setTitle(String(describing: malScore), for: UIControlState.normal)
            }
            cell.imageThumbnail.image = nil
            
            // checks the cache, and downloads the image or uses the one in the cache
            let img = imageCache.object(forKey: mangaSearchResults[indexPath.row].series_image! as NSString)
            cell.configureCell(manga: mangaSearchResults[indexPath.row], image: img, cache: imageCache)
        }
        
        cell.numCompleted.tintColor = UIColor.black
        cell.myScore.tintColor = UIColor.black
        cell.numCompleted.isUserInteractionEnabled = false
        cell.myScore.isUserInteractionEnabled = false
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MediaDetailsViewController") as! MediaDetailsViewController
        
        if (searchType == MiruGlobals.ANIME) {
            print("Selected: " + animeSearchResults[indexPath.row].series_title!)
            vc.anime = animeSearchResults[indexPath.row]
        } else {
            print("Selected: " + mangaSearchResults[indexPath.row].series_title!)
            vc.manga = mangaSearchResults[indexPath.row]
        }
        
        
        vc.imageCache = self.imageCache
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
