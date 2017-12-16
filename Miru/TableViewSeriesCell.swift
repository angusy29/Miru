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

    @IBOutlet weak var numCompleted: UILabel! // number of episodes or chapters completed
    
    @IBOutlet weak var myScore: UIButton!
    
    @IBOutlet weak var incrementChapterEpisodeButton: UIButton!
    
    var anime: Anime?
    var manga: Manga?
    
    // increments the chapter or episode
    @IBAction func incEpisode(_ sender: Any) {
        guard let watchedEpisodes = anime?.my_watched_episodes else { return }
        guard let id = anime?.series_animedb_id else { return }
        let nextEpisode = watchedEpisodes + 1
        
        malkit.updateAnime(id, params:["episode": nextEpisode], completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                DispatchQueue.main.async {
                    self.numCompleted.text = self.anime?.series_episodes! == 0 ? String(describing: nextEpisode) : String(describing: nextEpisode) + "/" + String(describing: (self.anime?.series_episodes)!)
                }
                self.anime?.my_watched_episodes = self.anime?.my_watched_episodes.map({ $0 + 1 })
            }
        })
    }
    
    @IBAction func incChapter(_ sender: Any) {
        guard let readChapters = manga?.my_read_chapters else { return }
        guard let id = manga?.series_mangadb_id else { return }
        let nextChapter = readChapters + 1
        
        malkit.updateManga(id, params:["chapter": nextChapter], completionHandler: { (result, status, err) in
            //20 is manga_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                DispatchQueue.main.async {
                    self.numCompleted.text = self.manga?.series_chapters! == 0 ? String(describing: nextChapter) : String(describing: nextChapter) + "/" + String(describing: (self.manga?.series_chapters)!)
                }
                self.manga?.my_read_chapters = self.manga?.my_read_chapters.map({ $0 + 1 })
            }
        })
    }
    
    func configureCell(anime: Anime, image: UIImage?, cache: NSCache<NSString, UIImage>){
        self.anime = anime
        
        if anime.my_watched_episodes! == anime.series_episodes!
            || anime.series_status == MiruGlobals.NOT_YET_RELEASED {
            incrementChapterEpisodeButton.isHidden = true
        } else {
            incrementChapterEpisodeButton.isHidden = false
            incrementChapterEpisodeButton.layer.cornerRadius = 8
        }
        
        if image != nil{
            //The image exist so you assign it to your UIImageView
            imageThumbnail.image = image
        } else {
            //Create the request to download the image
            if let seriesImage = anime.series_image {
                let url = URL(string: seriesImage)
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.imageThumbnail.image = UIImage(data: data!)
                        cache.setObject(self.imageThumbnail.image!, forKey: anime.series_image! as NSString)
                    }
                }
            }
        }
    }
    
    func configureCell(manga: Manga, image: UIImage?, cache: NSCache<NSString, UIImage>){
        self.manga = manga
        
        if manga.my_read_chapters! == manga.series_chapters!
            || manga.series_status == MiruGlobals.NOT_YET_RELEASED {
            incrementChapterEpisodeButton.isHidden = true
        } else {
            incrementChapterEpisodeButton.isHidden = false
            incrementChapterEpisodeButton.layer.cornerRadius = 8
        }

        if image != nil{
            //The image exist so you assign it to your UIImageView
            imageThumbnail.image = image
        } else {
            //Create the request to download the image
            if let seriesImage = manga.series_image {
                let url = URL(string: seriesImage)
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.imageThumbnail.image = UIImage(data: data!)
                        cache.setObject(self.imageThumbnail.image!, forKey: manga.series_image! as NSString)
                    }
                }
            }
        }
    }
    
    // rip encapsulation
    @IBAction func scoreButtonPressed(_ sender: Any) {
        let tableView = self.superview as! UITableView
        let vc = tableView.dataSource as! ListViewController
        
        if manga == nil {
            guard let anime = self.anime else { return }
            vc.showPickerView(anime: anime, cell: self)
        } else {
            guard let manga = self.manga else { return }
            vc.showPickerView(manga: manga, cell: self)
        }
    }
}
