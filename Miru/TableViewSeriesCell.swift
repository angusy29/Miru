//
//  TableViewSeriesCell.swift
//  Miru
//
//  Created by Angus Yuen on 15/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

class TableViewSeriesCell: UITableViewCell {
    
    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var airingStatus: UILabel!

    @IBOutlet weak var numCompleted: UIButton! // number of episodes or chapters completed
    
    @IBOutlet weak var MALMyScoreLabel: UILabel!
    @IBOutlet weak var myScore: UIButton!
    
    @IBOutlet weak var incrementChapterEpisodeButton: UIButton!
    
    var anime: Anime?       // if nil, this cell is manga
    var manga: Manga?       // if nil, this cell is anime
    
    var delegate: TableViewSeriesCellProtocol!

    // increments the chapter or episode
    @IBAction func incEpisode(_ sender: Any) {
        guard let watchedEpisodes = anime?.my_watched_episodes else { return }
        guard let id = anime?.series_animedb_id else { return }
        let nextEpisode = watchedEpisodes + 1
        
        self.delegate.isUpdating()
        malkit.updateAnime(id, params:["episode": nextEpisode], completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                self.anime?.my_watched_episodes = self.anime?.my_watched_episodes.map({ $0 + 1 })
                self.delegate.finishUpdating()
                DispatchQueue.main.async {
                    let numCompletedTitle = self.anime?.series_episodes! == 0 ? String(describing: nextEpisode) : String(describing: nextEpisode) + "/" + String(describing: (self.anime?.series_episodes)!)
                    self.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
                }
            } else {
                self.delegate.finishUpdating()
            }
        })
    }
    
    @IBAction func incChapter(_ sender: Any) {
        guard let readChapters = manga?.my_read_chapters else { return }
        guard let id = manga?.series_mangadb_id else { return }
        let nextChapter = readChapters + 1
        
        self.delegate.isUpdating()
        malkit.updateManga(id, params:["chapter": nextChapter], completionHandler: { (result, status, err) in
            //20 is manga_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                self.manga?.my_read_chapters = self.manga?.my_read_chapters.map({ $0 + 1 })
                self.delegate.finishUpdating()
                DispatchQueue.main.async {
                    let numCompletedTitle = self.manga?.series_chapters! == 0 ? String(describing: nextChapter) : String(describing: nextChapter) + "/" + String(describing: (self.manga?.series_chapters)!)
                    self.numCompleted.setTitle(numCompletedTitle, for: UIControlState.normal)
                }
            } else {
                self.delegate.finishUpdating()
            }
        })
    }
    
    func configureCell(anime: Anime, image: UIImage?, cache: NSCache<NSString, UIImage>){
        self.anime = anime
        
        if let watched_eps = anime.my_watched_episodes {
            if watched_eps == anime.series_episodes!
                || anime.series_status == MiruGlobals.NOT_YET_RELEASED {
                incrementChapterEpisodeButton.isHidden = true
                // numCompleted.isEnabled = false
            } else {
                showIncrementButton()
            }
        } else {
            incrementChapterEpisodeButton.isHidden = true
        }
        
        Util.setImage(anime: anime, imageViewToSet: self.imageThumbnail, image: image, cache: cache)
    }
    
    func configureCell(manga: Manga, image: UIImage?, cache: NSCache<NSString, UIImage>){
        self.manga = manga
        
        if let read_chapters = manga.my_read_chapters {
            if read_chapters == manga.series_chapters!
                || manga.series_status == MiruGlobals.NOT_YET_RELEASED {
                incrementChapterEpisodeButton.isHidden = true
                // numCompleted.isEnabled = false
            } else {
                showIncrementButton()
            }
        } else {
            incrementChapterEpisodeButton.isHidden = true
        }

        Util.setImage(manga: manga, imageViewToSet: self.imageThumbnail, image: image, cache: cache)
    }
    
    @IBAction func watchedReadButtonPressed(_ sender: Any) {
        let tableView = self.superview as! UITableView
        let vc = tableView.dataSource as! ListViewController
        
        if manga == nil {
            guard let anime = self.anime else { return }
            vc.showPickerView(anime: anime, cell: self, type: MiruGlobals.CHANGE_EPISODE_OR_CHAPTER)
        } else {
            guard let manga = self.manga else { return }
            vc.showPickerView(manga: manga, cell: self, type: MiruGlobals.CHANGE_EPISODE_OR_CHAPTER)
        }
    }
    
    // rip encapsulation
    @IBAction func scoreButtonPressed(_ sender: Any) {
        let tableView = self.superview as! UITableView
        let vc = tableView.dataSource as! ListViewController
        
        if manga == nil {
            guard let anime = self.anime else { return }
            vc.showPickerView(anime: anime, cell: self, type: MiruGlobals.CHANGE_SCORE)
        } else {
            guard let manga = self.manga else { return }
            vc.showPickerView(manga: manga, cell: self, type: MiruGlobals.CHANGE_SCORE)
        }
    }
    
    func showIncrementButton() {
        incrementChapterEpisodeButton.isHidden = false
        incrementChapterEpisodeButton.layer.cornerRadius = 8
    }
}
