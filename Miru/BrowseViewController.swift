//
//  BrowseViewController.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import UIKit
import Foundation

class BrowseViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate {
    var animeSearchResults = [Anime]()
    var mangaSearchResults = [Manga]()
    
    var popularAnimeList = [Anime]()       // anime names
    var topAiringAnimeList = [Anime]()         // top airing names
    var topUpcomingAnimeList = [Anime]()
    
    var searchResultTableViewController: UITableViewController!
    
    var searchController: UISearchController?

    // XML parsing attributes
    var currentXMLElement: String?
    var currentAnimeObj: Anime?
    var currentMangaObj: Manga?
    
    var imageCache = NSCache<NSString, UIImage>()
    var searchType: Int?        // MiruGlobal.ANIME or MiruGlobals.MANGA
    
    @IBOutlet weak var mostPopularAnimeCollection: UICollectionView!
    
    @IBOutlet weak var topAiringAnimeCollection: UICollectionView!
    
    @IBOutlet weak var topUpcomingAnimeCollection: UICollectionView!
    
    var rootNavigationController: RootNavigationController?

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.topItem?.searchController = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.topItem?.title = "Browse"
        
        // place search controller in navigation bar
        self.navigationController?.navigationBar.topItem?.searchController = searchController
        self.navigationController?.navigationBar.topItem?.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.rootNavigationController = self.navigationController as? RootNavigationController

        // Do any additional setup after loading the view, typically from a nib.
        searchResultTableViewController = (self.storyboard?.instantiateViewController(withIdentifier: "SearchResultTableViewController"))! as! UITableViewController
        searchController = UISearchController(searchResultsController: searchResultTableViewController)
 
        // set up search controller
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.scopeButtonTitles = ["Anime", "Manga"]
        searchController?.searchBar.delegate = self
        searchController?.searchBar.searchBarStyle = UISearchBarStyle.minimal
        searchController?.searchBar.placeholder = "Search"
        searchController?.searchBar.tintColor = UIColor.white
        
        self.searchResultTableViewController.tableView.register(UINib(nibName: "TableViewSeriesCell", bundle: nil), forCellReuseIdentifier: "TableViewSeriesCell")
        self.searchResultTableViewController.tableView.delegate = self
        self.searchResultTableViewController.tableView.dataSource = self

        self.mostPopularAnimeCollection.register(UINib.init(nibName: "BrowseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        self.mostPopularAnimeCollection.delegate = self
        self.mostPopularAnimeCollection.dataSource = self

        self.topUpcomingAnimeCollection.register(UINib.init(nibName: "BrowseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        self.topUpcomingAnimeCollection.delegate = self
        self.topUpcomingAnimeCollection.dataSource = self
        
        self.topAiringAnimeCollection.register(UINib.init(nibName: "BrowseCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BrowseCollectionViewCell")
        self.topAiringAnimeCollection.delegate = self
        self.topAiringAnimeCollection.dataSource = self
        
        searchHomePageMAL()
    }
    
    func searchHomePageMAL() {
        let url = URL(string: "https://myanimelist.net")
        
        guard let unwrapURL = url else { return }
        
        let sem = DispatchSemaphore.init(value: 0)
        
        URLSession.shared.dataTask(with: unwrapURL) { data, response, error in
            guard let data = data, error == nil else {
                print("\(error)")
                return
            }
            
            var string = String(data: data, encoding: .utf8)
            var popularRanking = string?.slice(from: "<div class=\"widget popular_ranking right\">", to: "</div>")
            var topAiring = string?.slice(from: "<div class=\"widget airing_ranking right\">", to: "</div>")
            var upcomingRanking = string?.slice(from: "<div class=\"widget upcoming_ranking right\">", to: "</div>")
            guard let unwrapPopular = popularRanking else { return }
            guard let unwrapTopAiring = topAiring else { return }
            guard let unwrapUpcoming = upcomingRanking else { return }
            
            self.populateMatches(html: unwrapPopular, type: "popular")
            self.populateMatches(html: unwrapTopAiring, type: "top_airing")
            self.populateMatches(html: unwrapUpcoming, type: "upcoming")
            sem.signal()
        }.resume()
        sem.wait()
        self.mostPopularAnimeCollection.reloadData()
    }
    
    func populateMatches(html: String, type: String) {
        var animeTitleRegex = NSRegularExpression()
        var animeImageRegex = NSRegularExpression()
        var animeIdRegex = NSRegularExpression()
        do {
            animeTitleRegex = try NSRegularExpression(pattern: "alt=\"(.+?)\"", options: [])
            animeImageRegex = try NSRegularExpression(pattern: "1x, (.+?) 2x", options: [])
            animeIdRegex = try NSRegularExpression(pattern: "<a class=\"title\" href=\"https://myanimelist.net/anime/(.+?)/", options: [])
        } catch {
            
        }
        
        var matches = animeTitleRegex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        var imageMatches = animeImageRegex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        var idMatches = animeIdRegex.matches(in: html, options: [], range: NSRange(location: 0, length: html.utf16.count))
        var i = 0
        for match in matches as [NSTextCheckingResult] {
            // range at index 0: full match
            // range at index 1: first capture group
            let substring = (html as! NSString).substring(with: match.range(at: 1))
            let imageSubstring = (html as! NSString).substring(with: imageMatches[i].range(at: 1))
            let idString = (html as! NSString).substring(with: idMatches[i].range(at: 1))

            let newAnime = Anime()
            newAnime.series_animedb_id = Int(idString)
            newAnime.series_title = substring
            newAnime.series_image = imageSubstring
            if type == "popular" {
                self.popularAnimeList.append(newAnime)
            } else if type == "top_airing" {
                self.topAiringAnimeList.append(newAnime)
            } else if type == "upcoming" {
                self.topUpcomingAnimeList.append(newAnime)
            }
            
            i += 1
        }
    }
    
    // On typing, this gets called to change the colour of the search bar text, because default is black
    func updateSearchResults(for searchController: UISearchController) {
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = self.searchController?.searchBar.text else { return }
        if (searchText.count < 3) {
            // need to let user know to input more than 3 chars
            return
        }
        
        searchType = self.searchController?.searchBar.selectedScopeButtonIndex
        if searchController?.searchBar.selectedScopeButtonIndex == MiruGlobals.ANIME {
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
            self.searchResultTableViewController.tableView.reloadData()

        } else if searchController?.searchBar.selectedScopeButtonIndex == MiruGlobals.MANGA {
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
            
            self.searchResultTableViewController.tableView.reloadData()
        }
        searchController?.searchBar.resignFirstResponder()
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
        let cell = self.searchResultTableViewController.tableView.dequeueReusableCell(withIdentifier: "TableViewSeriesCell") as! TableViewSeriesCell
        
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
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mostPopularAnimeCollection {
            return popularAnimeList.count
        } else if collectionView == topAiringAnimeCollection {
            return topAiringAnimeList.count
        } else {
            return topUpcomingAnimeList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BrowseCollectionViewCell", for: indexPath) as! BrowseCollectionViewCell
        
        if collectionView == mostPopularAnimeCollection {
            let img = self.rootNavigationController?.imageCache.object(forKey: popularAnimeList[indexPath.row].series_image as! NSString)
            Util.setImage(anime: popularAnimeList[indexPath.row], imageViewToSet: cell.imageView, image: img, cache: (self.rootNavigationController?.imageCache)!)
            cell.name.text = self.popularAnimeList[indexPath.row].series_title
        } else if collectionView == topAiringAnimeCollection {
            let img = self.rootNavigationController?.imageCache.object(forKey: topAiringAnimeList[indexPath.row].series_image as! NSString)
            Util.setImage(anime: topAiringAnimeList[indexPath.row], imageViewToSet: cell.imageView, image: img, cache: (self.rootNavigationController?.imageCache)!)
            cell.name.text = self.topAiringAnimeList[indexPath.row].series_title
        } else if collectionView == topUpcomingAnimeCollection {
            let img = self.rootNavigationController?.imageCache.object(forKey: topUpcomingAnimeList[indexPath.row].series_image as! NSString)
            Util.setImage(anime: topUpcomingAnimeList[indexPath.row], imageViewToSet: cell.imageView, image: img, cache: (self.rootNavigationController?.imageCache)!)
            cell.name.text = self.topUpcomingAnimeList[indexPath.row].series_title
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MediaDetailsViewController") as! MediaDetailsViewController
        var animeToPass = Anime()
        if collectionView == mostPopularAnimeCollection {
            animeToPass = popularAnimeList[indexPath.row]
            vc.anime = animeToPass
        } else if collectionView == topAiringAnimeCollection {
            animeToPass = topAiringAnimeList[indexPath.row]
            vc.anime = animeToPass
        } else if collectionView == topUpcomingAnimeCollection {
            animeToPass = topUpcomingAnimeList[indexPath.row]
            vc.anime = animeToPass
        }
        print("TEST")
        print(animeToPass.series_animedb_id)
        print(animeToPass.series_title)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
