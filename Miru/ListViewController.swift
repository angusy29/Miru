//
//  ListViewController.swift
//  Miru
//
//  Created by Angus Yuen on 15/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import EHHorizontalSelectionView
import Foundation
import UIKit

class ListViewController: UIViewController, EHHorizontalSelectionViewProtocol, XMLParserDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var horizontalView: EHHorizontalSelectionView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    
    // horizontal view states
    var states = [MiruGlobals.WATCHING_OR_READING,
                  MiruGlobals.COMPLETED,
                  MiruGlobals.ON_HOLD,
                  MiruGlobals.DROPPED,
                  MiruGlobals.PLAN_TO_WATCH_OR_READ]
    var selectedState = MiruGlobals.WATCHING_OR_READING
    
    // picker view selected item
    var selectedPickerViewItem: Int?
    
    // cache for images
    var imageCache = NSCache<NSString, UIImage>()
    
    // XML parsing variables
    var currentXMLElement: String?   // xml element we are looking at in XML file eg. <my_status>
    var type: String?
    
    // picker view data source
    var scores = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var scoreString = ["-", "(1) Appalling", "(2) Horrible", "(3) Very bad", "(4) Bad", "(5) Average", "(6) Fine", "(7) Good", "(8) Very good", "(9) Great", "(10) Masterpiece"]
    var episodesOrChapters = [Int]()
    
    // Used for changing scores for the anime/manga
    // this is actually so bad practice.....
    var anime: Anime?
    var manga: Manga?
    var cell: TableViewSeriesCell?      // cell to modify
    var pickerViewModifyType: Int?   // "score" or "episode", denotes which one to change in pickerview
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true

        // horizontal view initialise
        self.horizontalView.delegate = self
        EHHorizontalLineViewCell.updateFont(UIFont.systemFont(ofSize: 14))
        EHHorizontalLineViewCell.updateFontMedium(UIFont.boldSystemFont(ofSize: 16))
        EHHorizontalLineViewCell.updateColorHeight(2)
        
        // refresh initialise
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data from myanimelist.net")
        tableView.refreshControl = refreshControl
        
        // picker view initialise
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        hidePickerView()
    }
    
    @objc func refreshList(refreshControl: UIRefreshControl) {
        guard let type = self.type else { return }
        getList(type: type)
        tableView.reloadData()
        // somewhere in your code you might need to call:
        refreshControl.endRefreshing()
    }
    
    // Get list for that type
    func getList(type: String) {
        guard let username = MiruGlobals.username else { return }
        self.type = type
        let url = URL(string: "https://myanimelist.net/malappinfo.php?u=" + username + "&status=all&type=" + type)
        
        let sem = DispatchSemaphore.init(value: 0)
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            // print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
                sem.signal()
            }
            }.resume()
        
        sem.wait()
    }
    
    // EHHorizontal Protocol
    func horizontalSelection(_ selectionView: EHHorizontalSelectionView, didSelectObjectAt index: UInt) {
        self.selectedState = states[Int(index)]
        self.tableView.reloadData()
    }
    
    func numberOfItems(inHorizontalSelection hSelView: EHHorizontalSelectionView) -> UInt {
        return UInt(states.count)
    }
    
    // PickerView protocol
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerViewModifyType == MiruGlobals.CHANGE_SCORE {
            return scores.count
        }
        return episodesOrChapters.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerViewModifyType == MiruGlobals.CHANGE_SCORE {
            self.selectedPickerViewItem = scores[row]
        } else {
            self.selectedPickerViewItem = episodesOrChapters[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerViewModifyType == MiruGlobals.CHANGE_SCORE {
            return scoreString[row]
        }
        return String(episodesOrChapters[row])
    }
    
    @IBAction func pickerSavePress(_ sender: Any) {
        if pickerViewModifyType == MiruGlobals.CHANGE_SCORE {
            guard let score = self.selectedPickerViewItem else { return }
            if self.manga == nil {
                // UPDATE ANIME SCORE
                guard let id = self.anime?.series_animedb_id else { return }
                malkit.updateAnime(id, params:["score": score], completionHandler: { (result, status, err) in
                    if (result!) {
                        DispatchQueue.main.async {
                            let scoreTitle = score == 0 ? "-" : String(describing: score)
                            self.cell?.myScore.setTitle(scoreTitle, for: UIControlState.normal)
                        }
                        self.anime?.my_score = score
                    }
                })
            } else {
                // UPDATE MANGA SCORE
                guard let id = self.manga?.series_mangadb_id else { return }
                malkit.updateManga(id, params:["score": score], completionHandler: { (result, status, err) in
                    if (result!) {
                        DispatchQueue.main.async {
                            let scoreTitle = score == 0 ? "-" : String(describing: score)
                            self.cell?.myScore.setTitle(scoreTitle, for: UIControlState.normal)
                        }
                        self.manga?.my_score = score
                    }
                })
            }
        } else if pickerViewModifyType == MiruGlobals.CHANGE_EPISODE_OR_CHAPTER {
            guard let change = self.selectedPickerViewItem else { return }
            if self.manga == nil {
                // UPDATE ANIME EPISODE
                guard let id = self.anime?.series_animedb_id else { return }
                guard let anime = self.anime else { return }
                malkit.updateAnime(id, params:["episode": change], completionHandler: { (result, status, err) in
                    if (result!) {
                        DispatchQueue.main.async {
                            let numCompletedTitle = anime.series_episodes! == 0 ? String(describing: anime.my_watched_episodes!) : String(describing: anime.my_watched_episodes!) + "/" + String(describing: anime.series_episodes!)
                            self.cell?.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
                        }
                        self.anime?.my_watched_episodes = change
                    }
                })
            } else {
                // UPDATE MANGA CHAPTER
                guard let id = self.manga?.series_mangadb_id else { return }
                guard let manga = self.manga else { return }
                malkit.updateAnime(id, params:["chapter": change], completionHandler: { (result, status, err) in
                    if (result!) {
                        DispatchQueue.main.async {
                            let numCompletedTitle = manga.series_chapters! == 0 ? String(describing: manga.my_read_chapters!) : String(describing: manga.my_read_chapters!) + "/" + String(describing: manga.series_chapters!)
                            self.cell?.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
                        }
                        self.manga?.my_read_chapters = change
                    }
                })
            }
        }
        
        hidePickerView()
    }
    
    @IBAction func pickerCancelPress(_ sender: Any) {
        hidePickerView()
    }
    
    
    // Saves the manga, then hides the picker view
    func showPickerView(manga: Manga, cell: TableViewSeriesCell, type: Int) {
        self.manga = manga
        self.anime = nil
        self.cell = cell
        self.pickerViewModifyType = type
        self.pickerView.isHidden = false
        self.pickerToolbar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        if type == MiruGlobals.CHANGE_EPISODE_OR_CHAPTER {
            episodesOrChapters.removeAll()
            episodesOrChapters = manga.series_chapters != 0 ? (0...manga.series_chapters!).map{ $0 } : (0...manga.my_read_chapters!).map{ $0 }
        }
        
        self.pickerView.reloadAllComponents()

        // set default row of pickerview
        if type == MiruGlobals.CHANGE_EPISODE_OR_CHAPTER {
            if let read_chapters = manga.my_read_chapters {
                self.pickerView.selectRow(read_chapters, inComponent: 0, animated: false)
            }
        } else {
            if let score = manga.my_score {
                self.pickerView.selectRow(score, inComponent: 0, animated: false)
            }
        }
    }
    
    // Saves the anime, then hides the picker view
    func showPickerView(anime: Anime, cell: TableViewSeriesCell, type: Int) {
        self.anime = anime
        self.manga = nil
        self.cell = cell
        self.pickerViewModifyType = type
        self.pickerView.isHidden = false
        self.pickerToolbar.isHidden = false
        self.tabBarController?.tabBar.isHidden = true
        
        if type == MiruGlobals.CHANGE_EPISODE_OR_CHAPTER {
            episodesOrChapters.removeAll()
            episodesOrChapters = anime.series_episodes != 0 ? (0...anime.series_episodes!).map{ $0 } : (0...anime.my_watched_episodes!).map{ $0 }
        }
        self.pickerView.reloadAllComponents()
        
        // set default row of pickerview
        if type == MiruGlobals.CHANGE_EPISODE_OR_CHAPTER {
            if let watched_episodes = anime.my_watched_episodes {
                self.pickerView.selectRow(watched_episodes, inComponent: 0, animated: false)
            }
        } else {
            if let score = anime.my_score {
                self.pickerView.selectRow(score, inComponent: 0, animated: false)
            }
        }
    }
    
    func hidePickerView() {
        self.pickerToolbar.isHidden = true
        self.pickerView.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func titleForItem(at index: UInt, forHorisontalSelection hSelView: EHHorizontalSelectionView) -> String? {
        if self.states[Int(index)] == MiruGlobals.WATCHING_OR_READING {
            return "Currently watching"
        } else if self.states[Int(index)] == MiruGlobals.COMPLETED {
            return "Completed"
        } else if self.states[Int(index)] == MiruGlobals.ON_HOLD {
            return "On hold"
        } else if self.states[Int(index)] == MiruGlobals.DROPPED {
            return "Dropped"
        } else {
            return "Plan to watch"
        }
    }
}
