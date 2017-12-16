//
//  MangaListViewController.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import UIKit
import Foundation

class MangaListViewController: ListViewController, UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource {
    var idToManga = [Int: Manga]()
    var currentlyReading = [Manga]()
    var completed = [Manga]()
    var onHold = [Manga]()
    var dropped = [Manga]()
    var planToRead = [Manga]()
    
    var currentMangaObj: Manga?
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.title = "Manga list"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        getList(type: "manga")
        
        // sort by alphabetical order
        currentlyReading = currentlyReading.sorted(by: { $0.series_title! < $1.series_title! })
        completed = completed.sorted(by: { $0.series_title! < $1.series_title! })
        onHold = onHold.sorted(by: { $0.series_title! < $1.series_title! })
        dropped = dropped.sorted(by: { $0.series_title! < $1.series_title! })
        planToRead = planToRead.sorted(by: { $0.series_title! < $1.series_title! })
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if (elementName == "manga") {
            // create new anime object
            currentMangaObj = Manga()
        }
        currentXMLElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        var mangaObj = currentMangaObj
        if mangaObj?.series_mangadb_id != nil {
            guard let id = mangaObj?.series_mangadb_id else { return }
            if idToManga[id] != nil {
                mangaObj = idToManga[id]
            }
        }
        
        if (currentXMLElement == "series_mangadb_id") {
            mangaObj?.series_mangadb_id = Int(string)
        } else if (currentXMLElement == "series_title") {
            guard let id = mangaObj?.series_mangadb_id else { return }
            if idToManga[id] == nil {
                mangaObj?.series_title = mangaObj?.series_title == nil ? string : (mangaObj?.series_title)! + string
            }
        } else if (currentXMLElement == "series_synonyms") {
            guard let id = mangaObj?.series_mangadb_id else { return }
            if idToManga[id] == nil {
                mangaObj?.series_synonyms?.append(string)
            }
        } else if (currentXMLElement == "series_type") {
            mangaObj?.series_type = Int(string)
        } else if (currentXMLElement == "series_chapters") {
            mangaObj?.series_chapters = Int(string)
        } else if (currentXMLElement == "series_volumes") {
            mangaObj?.series_volumes = Int(string)
        } else if (currentXMLElement == "series_status") {
            mangaObj?.series_status = Int(string)
        } else if (currentXMLElement == "series_start") {
            
        } else if (currentXMLElement == "series_end") {
            
        } else if (currentXMLElement == "series_image") {
            mangaObj?.series_image = string
        } else if (currentXMLElement == "my_read_chapters") {
            mangaObj?.my_read_chapters = Int(string)
        } else if (currentXMLElement == "my_read_volumes") {
            mangaObj?.my_read_volumes = Int(string)
        } else if (currentXMLElement == "my_start_date") {
            
        } else if (currentXMLElement == "my_finish_date") {
            
        } else if (currentXMLElement == "my_score") {
            mangaObj?.my_score = Int(string)
        } else if (currentXMLElement == "my_status") {
            mangaObj?.my_status = Int(string)
        } else if (currentXMLElement == "my_rereadingg") {
            mangaObj?.my_rereadingg = Int(string)
        } else if (currentXMLElement == "my_rereading_chap") {
            mangaObj?.my_rereading_chap = Int(string)
        } else if (currentXMLElement == "my_last_updated") {
            
        } else if (currentXMLElement == "my_tags") {
            
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "manga") {
            guard let mangaObj = currentMangaObj else { return }
            guard let status = currentMangaObj?.my_status else { return }
            guard let id = mangaObj.series_mangadb_id else { return }
            
            // if the anime already exists, we update it
            if idToManga[id] != nil {
                idToManga[id] = mangaObj
                currentMangaObj = nil
                return
            }
            
            if (status == MiruGlobals.WATCHING_OR_READING) {
                currentlyReading.append(mangaObj)
            } else if (status == MiruGlobals.COMPLETED) {
                completed.append(mangaObj)
            } else if (status == MiruGlobals.DROPPED) {
                dropped.append(mangaObj)
            } else if (status == MiruGlobals.ON_HOLD) {
                onHold.append(mangaObj)
            } else if (status == MiruGlobals.PLAN_TO_WATCH_OR_READ) {
                planToRead.append(mangaObj)
            }
            idToManga[id] = mangaObj
            currentMangaObj = nil
        }
    }
    
    // TableView protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSelectedMangaArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "CustomCell") as! TableViewSeriesCell
        
        // set the text from the data model
        // cell.textLabel?.text = self.currentlyWatching[indexPath.row].series_title
        let selectedMangaArray = getSelectedMangaArray()
        let selectedManga = selectedMangaArray[indexPath.row]
        cell.title.text = selectedManga.series_title
        
        // if score is 0, set the text to -, otherwise take the score we stored
        let scoreTitle = selectedManga.my_score! == 0 ? "-" : String(describing: selectedManga.my_score!)
        cell.myScore.setTitle(scoreTitle, for: UIControlState.normal)
                
        let numCompletedTitle = selectedManga.series_chapters! == 0 ? String(describing: selectedManga.my_read_chapters!) : String(describing: selectedManga.my_read_chapters!) + "/" + String(describing: selectedManga.series_chapters!)
        cell.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
        cell.imageThumbnail.image = nil
        
        // set airing status text
        if selectedManga.series_status == MiruGlobals.CURRENTLY_ONGOING {
            cell.airingStatus.text = "Ongoing"
        } else if selectedManga.series_status == MiruGlobals.FINISHED_AIRING {
            cell.airingStatus.text = "Finished"
        } else if selectedManga.series_status == MiruGlobals.NOT_YET_RELEASED {
            cell.airingStatus.text = "Not yet released"
        }
        
        // checks the cache, and downloads the image or uses the one in the cache
        let img = imageCache.object(forKey: selectedManga.series_image! as NSString)
        cell.configureCell(manga: selectedManga, image: img, cache: imageCache)
        
        return cell
    }
    
    /*
     * Looks at selected horizontal view state, and returns the array of anime
     * with that status
     */
    func getSelectedMangaArray() -> [Manga] {
        if self.selectedState == MiruGlobals.WATCHING_OR_READING {
            return self.currentlyReading
        } else if self.selectedState == MiruGlobals.COMPLETED {
            return self.completed
        } else if self.selectedState == MiruGlobals.ON_HOLD {
            return self.onHold
        } else if self.selectedState == MiruGlobals.DROPPED {
            return self.dropped
        } else {
            return self.planToRead
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
