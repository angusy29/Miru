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
    var currentMangaObj: Manga?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = "Manga list"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.        
        getList(type: "manga")
        sortMedia(type: "manga")
        
        self.tableView.register(UINib(nibName: "TableViewSeriesCell", bundle: nil), forCellReuseIdentifier: "TableViewSeriesCell")
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
            if self.rootNavigationController?.user?.idToManga[id] != nil {
                mangaObj = self.rootNavigationController?.user?.idToManga[id]
            }
        }
        
        if (currentXMLElement == "series_mangadb_id") {
            mangaObj?.series_mangadb_id = Int(string)
        } else if (currentXMLElement == "series_title") {
            guard let id = mangaObj?.series_mangadb_id else { return }
            if self.rootNavigationController?.user?.idToManga[id] == nil {
                mangaObj?.series_title = mangaObj?.series_title == nil ? string : (mangaObj?.series_title)! + string
            }
        } else if (currentXMLElement == "series_synonyms") {
            guard let id = mangaObj?.series_mangadb_id else { return }
            if self.rootNavigationController?.user?.idToManga[id] == nil {
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
        
        if (currentXMLElement == "user_reading") {
            self.rootNavigationController?.user?.user_manga_reading = Int(string)
        } else if (currentXMLElement == "user_completed") {
            self.rootNavigationController?.user?.user_manga_completed = Int(string)
        } else if (currentXMLElement == "user_onhold") {
            self.rootNavigationController?.user?.user_manga_onhold = Int(string)
        } else if (currentXMLElement == "user_dropped") {
            self.rootNavigationController?.user?.user_manga_dropped = Int(string)
        } else if (currentXMLElement == "user_plantoread") {
            self.rootNavigationController?.user?.user_manga_plantoread = Int(string)
        } else if (currentXMLElement == "user_days_spent_watching") {
            self.rootNavigationController?.user?.user_manga_days_spent_reading = Double(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "manga") {
            guard let mangaObj = currentMangaObj else { return }
            guard let status = currentMangaObj?.my_status else { return }
            guard let id = mangaObj.series_mangadb_id else { return }
            
            // if the anime already exists, we update it
            if self.rootNavigationController?.user?.idToManga[id] != nil {
                self.rootNavigationController?.user?.idToManga[id] = mangaObj
                currentMangaObj = nil
                return
            }
            
            if (status == MiruGlobals.WATCHING_OR_READING) {
                self.rootNavigationController?.user?.currentlyReading.append(mangaObj)
            } else if (status == MiruGlobals.COMPLETED) {
                self.rootNavigationController?.user?.completedManga.append(mangaObj)
            } else if (status == MiruGlobals.DROPPED) {
                self.rootNavigationController?.user?.droppedManga.append(mangaObj)
            } else if (status == MiruGlobals.ON_HOLD) {
                self.rootNavigationController?.user?.onHoldManga.append(mangaObj)
            } else if (status == MiruGlobals.PLAN_TO_WATCH_OR_READ) {
                self.rootNavigationController?.user?.planToRead.append(mangaObj)
            }
            self.rootNavigationController?.user?.idToManga[id] = mangaObj
            currentMangaObj = nil
        }
    }
    
    // TableView protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getSelectedMangaArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // create a new cell if needed or reuse an old one
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "TableViewSeriesCell") as! TableViewSeriesCell
        cell.delegate = self
        
        // set the text from the data model
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
        let img = self.rootNavigationController?.imageCache.object(forKey: selectedManga.series_image! as NSString)
        cell.configureCell(manga: selectedManga, image: img, cache: (self.rootNavigationController?.imageCache)!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MediaDetailsViewController") as! MediaDetailsViewController
        vc.manga = self.getSelectedMangaArray()[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /*
     * Looks at selected horizontal view state, and returns the array of anime
     * with that status
     */
    func getSelectedMangaArray() -> [Manga] {
        if self.selectedState == MiruGlobals.WATCHING_OR_READING {
            return (self.rootNavigationController?.user?.currentlyReading)!
        } else if self.selectedState == MiruGlobals.COMPLETED {
            return (self.rootNavigationController?.user?.completedManga)!
        } else if self.selectedState == MiruGlobals.ON_HOLD {
            return (self.rootNavigationController?.user?.onHoldManga)!
        } else if self.selectedState == MiruGlobals.DROPPED {
            return (self.rootNavigationController?.user?.droppedManga)!
        } else {
            return (self.rootNavigationController?.user?.planToRead)!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
