//
//  UserAnimeStatisticsTableView.swift
//  Miru
//
//  Created by Angus Yuen on 16/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

class UserStatisticsTableView: UITableView, XMLParserDelegate {
    @IBOutlet weak var watching: UITableViewCell!
    @IBOutlet weak var completed: UITableViewCell!
    @IBOutlet weak var onHold: UITableViewCell!
    @IBOutlet weak var dropped: UITableViewCell!
    @IBOutlet weak var planToWatch: UITableViewCell!
    @IBOutlet weak var daysSpentWatching: UITableViewCell!
    
    @IBOutlet weak var mangaReading: UITableViewCell!
    @IBOutlet weak var mangaCompleted: UITableViewCell!
    @IBOutlet weak var mangaOnHold: UITableViewCell!
    @IBOutlet weak var mangaDropped: UITableViewCell!
    @IBOutlet weak var mangaPlanToRead: UITableViewCell!
    @IBOutlet weak var daysSpentReading: UITableViewCell!
    
    var currentXMLElement: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("Awake")
        // get anime statistics
        // let's assume it's already loaded from animeListViewController, as that was landing page
        
        // get manga statistics
        getMangaStatistics()
        
        watching.detailTextLabel?.text = String(describing: MiruGlobals.user.user_watching!)
        completed.detailTextLabel?.text = String(describing: MiruGlobals.user.user_completed!)
        onHold.detailTextLabel?.text = String(describing: MiruGlobals.user.user_onhold!)
        dropped.detailTextLabel?.text = String(describing: MiruGlobals.user.user_dropped!)
        planToWatch.detailTextLabel?.text = String(describing: MiruGlobals.user.user_plantowatch!)
        daysSpentWatching.detailTextLabel?.text = String(describing: MiruGlobals.user.user_days_spent_watching!)
        
        mangaReading.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_reading!)
        mangaCompleted.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_completed!)
        mangaOnHold.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_onhold!)
        mangaDropped.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_dropped!)
        mangaPlanToRead.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_plantoread!)
        daysSpentReading.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_days_spent_reading!)
    }
    
    // get manga statistics, honestly same function as getList() from ListViewController
    func getMangaStatistics() {
        guard let username = MiruGlobals.username else { return }
        let url = URL(string: "https://myanimelist.net/malappinfo.php?u=" + username + "&status=all&type=manga")
        
        let sem = DispatchSemaphore.init(value: 0)
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
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
        currentXMLElement = elementName
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if (currentXMLElement == "user_reading") {
            MiruGlobals.user.user_manga_reading = Int(string)
        } else if (currentXMLElement == "user_completed") {
            MiruGlobals.user.user_manga_completed = Int(string)
        } else if (currentXMLElement == "user_onhold") {
            MiruGlobals.user.user_manga_onhold = Int(string)
        } else if (currentXMLElement == "user_dropped") {
            MiruGlobals.user.user_manga_dropped = Int(string)
        } else if (currentXMLElement == "user_plantoread") {
            MiruGlobals.user.user_manga_plantoread = Int(string)
        } else if (currentXMLElement == "user_days_spent_watching") {
            MiruGlobals.user.user_manga_days_spent_reading = Double(string)
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if (elementName == "myinfo") {
            parser.abortParsing()
        }
    }
}
