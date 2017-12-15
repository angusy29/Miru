//
//  AnimeListViewController.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import EHHorizontalSelectionView
import UIKit
import Foundation

class AnimeListViewController: ListViewController, UINavigationBarDelegate, XMLParserDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // anime arrays
    var currentlyWatching = [Anime]()
    var completed = [Anime]()
    var onHold = [Anime]()
    var dropped = [Anime]()
    var planToWatch = [Anime]()
    
    // Used to parse through XML, we know which anime to populate
    var currentAnimeObj: Anime?     // keeps track of the current anime to populate/create

    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Anime list"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // make API call
        getAnimeList()
        
        // sort by alphabetical order
        currentlyWatching = currentlyWatching.sorted(by: { $0.series_title! < $1.series_title! })
        completed = completed.sorted(by: { $0.series_title! < $1.series_title! })
        onHold = onHold.sorted(by: { $0.series_title! < $1.series_title! })
        dropped = dropped.sorted(by: { $0.series_title! < $1.series_title! })
        planToWatch = planToWatch.sorted(by: { $0.series_title! < $1.series_title! })
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func getAnimeList() {
        guard let username = MiruGlobals.username else { return }
        let url = URL(string: "https://myanimelist.net/malappinfo.php?u=" + username + "&status=all&type=anime")

        let sem = DispatchSemaphore.init(value: 0)
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
                sem.signal()
            }
        }.resume()
        
        sem.wait()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    
        if (elementName == "anime") {
            // create new anime object
            currentAnimeObj = Anime()
        }
        currentXMLElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let animeObj = currentAnimeObj else { return }
        if (currentXMLElement == "series_animedb_id") {
            animeObj.series_animedb_id = Int(string)
        } else if (currentXMLElement == "series_title") {
            animeObj.series_title = animeObj.series_title == nil ? string : animeObj.series_title! + string
        } else if (currentXMLElement == "series_synonyms") {
            animeObj.series_synonyms?.append(string)
        } else if (currentXMLElement == "series_type") {
            animeObj.series_type = Int(string)
        } else if (currentXMLElement == "series_episodes") {
            animeObj.series_episodes = Int(string)
        } else if (currentXMLElement == "series_status") {
            animeObj.series_status = Int(string)
        } else if (currentXMLElement == "series_start") {
            
        } else if (currentXMLElement == "series_end") {
            
        } else if (currentXMLElement == "series_image") {
            animeObj.series_image = string
        } else if (currentXMLElement == "my_watched_episodes") {
            animeObj.my_watched_episodes = Int(string)
        } else if (currentXMLElement == "my_start_date") {
            
        } else if (currentXMLElement == "my_finish_date") {
            
        } else if (currentXMLElement == "my_score") {
            animeObj.my_score = Int(string)
        } else if (currentXMLElement == "my_status") {
            animeObj.my_status = Int(string)
        } else if (currentXMLElement == "my_rewatching") {
            animeObj.my_rewatching = Int(string)
        } else if (currentXMLElement == "my_rewatching_ep") {
            animeObj.my_rewatching_ep = Int(string)
        } else if (currentXMLElement == "my_last_updated") {
            
        } else if (currentXMLElement == "my_tags") {
            
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "anime") {
            guard let animeObj = currentAnimeObj else { return }
            guard let status = currentAnimeObj?.my_status else { return }
            
            if (status == MiruGlobals.WATCHING_OR_READING) {
                currentlyWatching.append(animeObj)
            } else if (status == MiruGlobals.COMPLETED) {
                completed.append(animeObj)
            } else if (status == MiruGlobals.DROPPED) {
                dropped.append(animeObj)
            } else if (status == MiruGlobals.ON_HOLD) {
                onHold.append(animeObj)
            } else if (status == MiruGlobals.PLAN_TO_WATCH_OR_READ) {
                planToWatch.append(animeObj)
            }
            currentAnimeObj = nil
        }
    }
    
    // TableView protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSelectedAnimeArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! TableViewSeriesCell
        
        // set the text from the data model
        // cell.textLabel?.text = self.currentlyWatching[indexPath.row].series_title
        let selectedAnimeArray = getSelectedAnimeArray()
        let selectedAnime = selectedAnimeArray[indexPath.row]
        cell.title.text = selectedAnime.series_title
        
        // if score is 0, set the text to -, otherwise take the score we stored
        cell.myScore.text = selectedAnime.my_score! == 0 ? "-" : String(describing: selectedAnime.my_score!)
        
        cell.episodesWatched.text = selectedAnime.series_episodes! == 0 ? String(describing: selectedAnime.my_watched_episodes!) : String(describing: selectedAnime.my_watched_episodes!) + "/" + String(describing: selectedAnime.series_episodes!)
        cell.imageThumbnail.image = nil
        
        // set airing status text
        if selectedAnime.series_status == MiruGlobals.CURRENTLY_ONGOING {
            cell.airingStatus.text = "Airing"
        } else if selectedAnime.series_status == MiruGlobals.FINISHED_AIRING {
            cell.airingStatus.text = "Finished airing"
        } else if selectedAnime.series_status == MiruGlobals.NOT_YET_RELEASED {
            cell.airingStatus.text = "Not yet airing"
        }
        
        // checks the cache, and downloads the image or uses the one in the cache
        let img = imageCache.object(forKey: selectedAnime.series_image! as NSString)
        cell.configureCell(anime: selectedAnime, image: img, cache: imageCache)
        
        return cell
    }
    
    /*
     * Looks at selected horizontal view state, and returns the array of anime
     * with that status
     */
    func getSelectedAnimeArray() -> [Anime] {
        if self.selectedState == MiruGlobals.WATCHING_OR_READING {
            return self.currentlyWatching
        } else if self.selectedState == MiruGlobals.COMPLETED {
            return self.completed
        } else if self.selectedState == MiruGlobals.ON_HOLD {
            return self.onHold
        } else if self.selectedState == MiruGlobals.DROPPED {
            return self.dropped
        } else {
            return self.planToWatch
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
