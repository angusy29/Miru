//
//  EpisodeChapterPickerView.swift
//  Miru
//
//  Created by Angus Yuen on 1/01/18.
//  Copyright © 2018 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

class EpisodeChapterPickerView: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    
    // picker view selected item
    var selectedPickerViewItem: Int?
    
    // picker view data source
    var scores = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var scoreString = ["-", "(1) Appalling", "(2) Horrible", "(3) Very bad", "(4) Bad", "(5) Average", "(6) Fine", "(7) Good", "(8) Very good", "(9) Great", "(10) Masterpiece"]
    var episodesOrChapters = [Int]()
    
    // Used for changing scores for the anime/manga
    // this is actually so bad practice.....
    var anime: Anime?
    var manga: Manga?
    var cell: UITableViewCell?      // cell to modify
    var pickerViewModifyType: Int?   // "score" or "episode", denotes which one to change in pickerview
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // picker view initialise
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
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
    
    // save press on media details
    @IBAction func pickerSaveMediaDetailsPress(_ sender: Any) {
        if pickerViewModifyType == MiruGlobals.CHANGE_SCORE {
            guard let score = self.selectedPickerViewItem else { return }
            if self.manga == nil {
                // UPDATE ANIME SCORE
                guard let id = self.anime?.series_animedb_id else { return }
                malkit.updateAnime(id, params:["score": score], completionHandler: { (result, status, err) in
                    if (result!) {
                        DispatchQueue.main.async {
                            let scoreTitle = score == 0 ? "-" : String(describing: score)
                            self.cell?.detailTextLabel?.text = scoreTitle
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
                            self.cell?.detailTextLabel?.text = scoreTitle
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
                            self.cell?.detailTextLabel?.text = numCompletedTitle
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
                            self.cell?.detailTextLabel?.text = numCompletedTitle
                        }
                        self.manga?.my_read_chapters = change
                    }
                })
            }
        }
        hidePickerView()
    }
    
    // save press on anime list/manga list
    @IBAction func pickerSavePress(_ sender: Any) {
        let tableCell = self.cell as? TableViewSeriesCell
        if pickerViewModifyType == MiruGlobals.CHANGE_SCORE {
            guard let score = self.selectedPickerViewItem else { return }
            if self.manga == nil {
                // UPDATE ANIME SCORE
                guard let id = self.anime?.series_animedb_id else { return }
                malkit.updateAnime(id, params:["score": score], completionHandler: { (result, status, err) in
                    if (result!) {
                        DispatchQueue.main.async {
                            let scoreTitle = score == 0 ? "-" : String(describing: score)
                            tableCell?.myScore.setTitle(scoreTitle, for: UIControlState.normal)
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
                            tableCell?.myScore.setTitle(scoreTitle, for: UIControlState.normal)
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
                            tableCell?.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
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
                            tableCell?.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
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
    func showPickerView(manga: Manga, cell: UITableViewCell, type: Int) {
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
    func showPickerView(anime: Anime, cell: UITableViewCell, type: Int) {
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
        
        print("HELPPPP")
    }
    
    func hidePickerView() {
        self.pickerToolbar.isHidden = true
        self.pickerView.isHidden = true
        self.tabBarController?.tabBar.isHidden = false
    }
}
