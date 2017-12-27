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

class AnimeListViewController: ListViewController, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource {
    // Used to parse through XML, we know which anime to populate
    var currentAnimeObj: Anime?     // keeps track of the current anime to populate/create

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Anime list"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // make API call
        getList(type: "anime")
        
        // sort by alphabetical order
        MiruGlobals.user.currentlyWatching = MiruGlobals.user.currentlyWatching.sorted(by: { $0.series_title! < $1.series_title! })
        MiruGlobals.user.completedAnime = MiruGlobals.user.completedAnime.sorted(by: { $0.series_title! < $1.series_title! })
        MiruGlobals.user.onHoldAnime = MiruGlobals.user.onHoldAnime.sorted(by: { $0.series_title! < $1.series_title! })
        MiruGlobals.user.droppedAnime = MiruGlobals.user.droppedAnime.sorted(by: { $0.series_title! < $1.series_title! })
        MiruGlobals.user.planToWatch = MiruGlobals.user.planToWatch.sorted(by: { $0.series_title! < $1.series_title! })
        
        self.tableView.register(UINib(nibName: "TableViewSeriesCell", bundle: nil), forCellReuseIdentifier: "TableViewSeriesCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    
        if (elementName == "anime") {
            // create new anime object
            currentAnimeObj = Anime()
        }
        currentXMLElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        var animeObj = currentAnimeObj
        
        if animeObj?.series_animedb_id != nil {
            guard let id = animeObj?.series_animedb_id else { return }
            if MiruGlobals.user.idToAnime[id] != nil {
                animeObj = MiruGlobals.user.idToAnime[id]
            }
        }
        
        if (currentXMLElement == "series_animedb_id") {
            animeObj?.series_animedb_id = Int(string)
        } else if (currentXMLElement == "series_title") {
            guard let id = animeObj?.series_animedb_id else { return }
            if MiruGlobals.user.idToAnime[id] == nil {
                animeObj?.series_title = animeObj?.series_title == nil ? string : (animeObj?.series_title)! + string
            }
        } else if (currentXMLElement == "series_synonyms") {
            guard let id = animeObj?.series_animedb_id else { return }
            if MiruGlobals.user.idToAnime[id] == nil {
                animeObj?.series_synonyms?.append(string)
            }
        } else if (currentXMLElement == "series_type") {
            animeObj?.series_type = Int(string)
        } else if (currentXMLElement == "series_episodes") {
            animeObj?.series_episodes = Int(string)
        } else if (currentXMLElement == "series_status") {
            animeObj?.series_status = Int(string)
        } else if (currentXMLElement == "series_start") {
            
        } else if (currentXMLElement == "series_end") {
            
        } else if (currentXMLElement == "series_image") {
            animeObj?.series_image = string
        } else if (currentXMLElement == "my_watched_episodes") {
            animeObj?.my_watched_episodes = Int(string)
        } else if (currentXMLElement == "my_start_date") {
            
        } else if (currentXMLElement == "my_finish_date") {
            
        } else if (currentXMLElement == "my_score") {
            animeObj?.my_score = Int(string)
        } else if (currentXMLElement == "my_status") {
            animeObj?.my_status = Int(string)
        } else if (currentXMLElement == "my_rewatching") {
            animeObj?.my_rewatching = Int(string)
        } else if (currentXMLElement == "my_rewatching_ep") {
            animeObj?.my_rewatching_ep = Int(string)
        } else if (currentXMLElement == "my_last_updated") {
            
        } else if (currentXMLElement == "my_tags") {
            
        }
        
        if (currentXMLElement == "user_id") {
            MiruGlobals.user.user_id = Int(string)
            MiruGlobals.user.user_picture = "https://myanimelist.cdn-dena.com/images/userimages/" + string + ".jpg"
        } else if (currentXMLElement == "user_name") {
            MiruGlobals.user.user_name = string
        } else if (currentXMLElement == "user_watching") {
            MiruGlobals.user.user_watching = Int(string)
        } else if (currentXMLElement == "user_completed") {
            MiruGlobals.user.user_completed = Int(string)
        } else if (currentXMLElement == "user_onhold") {
            MiruGlobals.user.user_onhold = Int(string)
        } else if (currentXMLElement == "user_dropped") {
            MiruGlobals.user.user_dropped = Int(string)
        } else if (currentXMLElement == "user_plantowatch") {
            MiruGlobals.user.user_plantowatch = Int(string)
        } else if (currentXMLElement == "user_days_spent_watching") {
            MiruGlobals.user.user_days_spent_watching = Double(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "anime") {
            guard let animeObj = currentAnimeObj else { return }
            guard let status = currentAnimeObj?.my_status else { return }
            guard let id = animeObj.series_animedb_id else { return }
            
            // if the anime already exists, we update it
            if MiruGlobals.user.idToAnime[id] != nil {
                MiruGlobals.user.idToAnime[id] = animeObj
                currentAnimeObj = nil
                return
            }
            
            // otherwise we append the anime
            if (status == MiruGlobals.WATCHING_OR_READING) {
                MiruGlobals.user.currentlyWatching.append(animeObj)
            } else if (status == MiruGlobals.COMPLETED) {
                MiruGlobals.user.completedAnime.append(animeObj)
            } else if (status == MiruGlobals.DROPPED) {
                MiruGlobals.user.droppedAnime.append(animeObj)
            } else if (status == MiruGlobals.ON_HOLD) {
                MiruGlobals.user.onHoldAnime.append(animeObj)
            } else if (status == MiruGlobals.PLAN_TO_WATCH_OR_READ) {
                MiruGlobals.user.planToWatch.append(animeObj)
            }
            MiruGlobals.user.idToAnime[id] = animeObj
            currentAnimeObj = nil
        }
    }
    
    // TableView protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSelectedAnimeArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableViewSeriesCell") as! TableViewSeriesCell
        
        // set the text from the data model
        // cell.textLabel?.text = self.MiruGlobals.user.currentlyWatching[indexPath.row].series_title
        let selectedAnimeArray = getSelectedAnimeArray()
        let selectedAnime = selectedAnimeArray[indexPath.row]
        cell.title.text = selectedAnime.series_title
        
        // if score is 0, set the text to -, otherwise take the score we stored
        let scoreTitle = selectedAnime.my_score! == 0 ? "-" : String(describing: selectedAnime.my_score!)
        cell.myScore.setTitle(scoreTitle, for: UIControlState.normal)
        
        let numCompletedTitle = selectedAnime.series_episodes! == 0 ? String(describing: selectedAnime.my_watched_episodes!) : String(describing: selectedAnime.my_watched_episodes!) + "/" + String(describing: selectedAnime.series_episodes!)
        cell.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
        
        // set airing status text
        if selectedAnime.series_status == MiruGlobals.CURRENTLY_ONGOING {
            cell.airingStatus.text = "Airing"
        } else if selectedAnime.series_status == MiruGlobals.FINISHED_AIRING {
            cell.airingStatus.text = "Finished airing"
        } else if selectedAnime.series_status == MiruGlobals.NOT_YET_RELEASED {
            cell.airingStatus.text = "Not yet airing"
        }
        
        cell.imageThumbnail.image = nil

        // checks the cache, and downloads the image or uses the one in the cache
        let img = imageCache.object(forKey: selectedAnime.series_image! as NSString)
        cell.configureCell(anime: selectedAnime, image: img, cache: imageCache)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.getSelectedAnimeArray()[indexPath.row].series_title)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MediaDetailsViewController") as! MediaDetailsViewController
        vc.anime = self.getSelectedAnimeArray()[indexPath.row]
        vc.imageCache = self.imageCache
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
     * Looks at selected horizontal view state, and returns the array of anime
     * with that status
     */
    func getSelectedAnimeArray() -> [Anime] {
        if self.selectedState == MiruGlobals.WATCHING_OR_READING {
            return MiruGlobals.user.currentlyWatching
        } else if self.selectedState == MiruGlobals.COMPLETED {
            return MiruGlobals.user.completedAnime
        } else if self.selectedState == MiruGlobals.ON_HOLD {
            return MiruGlobals.user.onHoldAnime
        } else if self.selectedState == MiruGlobals.DROPPED {
            return MiruGlobals.user.droppedAnime
        } else {
            return MiruGlobals.user.planToWatch
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
