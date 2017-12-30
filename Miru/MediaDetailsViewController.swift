//
//  MediaDetailsViewController.swift
//  Miru
//
//  Created by Angus Yuen on 27/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

class MediaDetailsViewController: UIViewController {
    @IBOutlet weak var mediaNameLabel: UILabel!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    @IBOutlet weak var addToListButton: UIButton!
    
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var malScoreLabel: UILabel!
    
    var anime: Anime?
    var manga: Manga?
    var rootNavigationController: RootNavigationController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.topItem?.title = manga == nil ? anime?.series_title: manga?.series_title
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.rootNavigationController = self.navigationController as? RootNavigationController
        
        self.mediaNameLabel.text = manga == nil ? anime?.series_title : manga?.series_title
        
        if manga == nil {
            // it is anime
            let img = rootNavigationController?.imageCache.object(forKey: anime?.series_image! as! NSString)
            Util.setImage(anime: anime, imageViewToSet: mediaImageView, image: img, cache: (rootNavigationController?.imageCache)!)
            
            guard let id = anime?.series_animedb_id else { return }
            if self.rootNavigationController?.user?.idToAnime[id] != nil {
                setAddToListToMove()
            }
        } else {
            // it is a manga
            let img = rootNavigationController?.imageCache.object(forKey: manga?.series_image! as! NSString)
            Util.setImage(manga: manga, imageViewToSet: mediaImageView, image: img, cache: (rootNavigationController?.imageCache)!)
            
            guard let id = manga?.series_mangadb_id else { return }
            if self.rootNavigationController?.user?.idToManga[id] != nil {
                setAddToListToMove()
            }
        }
        
        DispatchQueue.main.async {
            let cacheObj = self.manga == nil ? self.rootNavigationController?.webscrapeCache.object(forKey: "anime" + String(describing: (self.anime?.series_animedb_id)!) as NSString) : self.rootNavigationController?.webscrapeCache.object(forKey: "manga" + String(describing: (self.manga?.series_mangadb_id)!) as NSString)
            let type = self.manga == nil ? "anime" : "manga"
            self.getDetails(cacheObj: cacheObj, type: type)
        }
    }
    
    func getDetails(cacheObj: WebscrapeMedia?, type: String) {
        if cacheObj != nil {
            print("CACHED")
            self.synopsisLabel.text = String(describing: (cacheObj?.synopsis)!)
            self.malScoreLabel.text = String(describing: (cacheObj?.malScore)!)
            return
        }
        
        
        let id = manga == nil ? (anime?.series_animedb_id)! : (manga?.series_mangadb_id)!
        let url = manga == nil ? URL(string: "https://myanimelist.net/anime/" + String(describing: id))! :
            URL(string: "https://myanimelist.net/manga/" + String(describing: id))!
        
        var synopsis: String?
        var malScore: String?
        let sem = DispatchSemaphore.init(value: 0)
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("\(error)")
                return
            }
            
            var string = String(data: data, encoding: .utf8)
            print("\(string)")
            synopsis = string?.slice(from: "<span itemprop=\"description\">", to: "</span>")
            malScore = string?.slice(from: "<span itemprop=\"ratingValue\">", to: "</span>")
            sem.signal()
        }.resume()
        
        sem.wait()
        
        guard let unwrap = synopsis else { return }
        guard let unwrapScore = malScore else { return }
        do {
            let syn = try! NSAttributedString(data: unwrap.data(using: String.Encoding.utf8)!,
                                                             options: [.documentType: NSAttributedString.DocumentType.html,
                                                                       .characterEncoding: String.Encoding.utf8.rawValue],
                                                             documentAttributes: nil)
            
            let score = try! NSAttributedString(data: unwrapScore.data(using: String.Encoding.utf8)!,
                                                options: [.documentType: NSAttributedString.DocumentType.html,
                                                          .characterEncoding: String.Encoding.utf8.rawValue],
                                                documentAttributes: nil)
            
            var newWebscrapeObject = WebscrapeMedia(synopsis: syn.string, malScore: score.string)
            self.rootNavigationController?.webscrapeCache.setObject(newWebscrapeObject, forKey: type + String(describing: id) as NSString)
            
            self.synopsisLabel.text = syn.string
            self.malScoreLabel.text = score.string
        }
    }
    
    func setAddToListToMove() {
        addToListButton.setTitle("Move to list", for: UIControlState.normal)
    }
    
    @IBAction func addToListButtonPressed(_ sender: Any) {
        var isInList = false
        if anime != nil {
            if rootNavigationController?.user?.idToAnime[(anime?.series_animedb_id)!] != nil {
                isInList = true
            }
        } else {
            if rootNavigationController?.user?.idToManga[(manga?.series_mangadb_id)!] != nil {
                isInList = true
            }
        }
        
        let actionController = UIAlertController(title: nil, message: "Add to list", preferredStyle: .actionSheet)
        
        let currentlyWatchingAction = UIAlertAction(title: "Currently watching", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
            if self.manga == nil {
                self.updateOrAddMedia(isInList: isInList, anime: self.anime, type: MiruGlobals.WATCHING_OR_READING)
            } else {
                self.updateOrAddMedia(isInList: isInList, manga: self.manga, type: MiruGlobals.WATCHING_OR_READING)
            }
        })
        
        let completedAction = UIAlertAction(title: "Completed", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.updateOrAddMedia(isInList: isInList, anime: self.anime, type: MiruGlobals.COMPLETED)
            } else {
                self.updateOrAddMedia(isInList: isInList, manga: self.manga, type: MiruGlobals.COMPLETED)
            }
        })
        
        let onHoldAction = UIAlertAction(title: "On hold", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.updateOrAddMedia(isInList: isInList, anime: self.anime, type: MiruGlobals.ON_HOLD)
            } else {
                self.updateOrAddMedia(isInList: isInList, manga: self.manga, type: MiruGlobals.ON_HOLD)
            }
        })
        
        let droppedAction = UIAlertAction(title: "Dropped", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.updateOrAddMedia(isInList: isInList, anime: self.anime, type: MiruGlobals.DROPPED)
            } else {
                self.updateOrAddMedia(isInList: isInList, manga: self.manga, type: MiruGlobals.DROPPED)
            }
        })
        
        let planToWatchAction = UIAlertAction(title: "Plan to watch", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.updateOrAddMedia(isInList: isInList, anime: self.anime, type: MiruGlobals.PLAN_TO_WATCH_OR_READ)
            } else {
                self.updateOrAddMedia(isInList: isInList, manga: self.manga, type: MiruGlobals.PLAN_TO_WATCH_OR_READ)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in
            //  Do something here upon cancellation.
        })
        
        actionController.addAction(currentlyWatchingAction)
        actionController.addAction(completedAction)
        actionController.addAction(onHoldAction)
        actionController.addAction(droppedAction)
        actionController.addAction(planToWatchAction)
        actionController.addAction(cancelAction)
        
        if isInList {
            actionController.message = "Move to list"
            let removeAction = UIAlertAction(title: "Remove from list", style: .destructive, handler: { (alert: UIAlertAction!) -> Void in
                if self.manga == nil {
                    self.removeMediaFromList(anime: self.anime)
                } else {
                    self.removeMediaFromList(manga: self.manga)
                }
            })
            
            actionController.addAction(removeAction)
        }
        self.present(actionController, animated: true, completion: nil)
    }
    
    func updateOrAddMedia(isInList: Bool, anime: Anime?, type: Int) {
        print("UPDATE OR ADD")
        if isInList {
            self.updateMedia(anime: anime, type: type)
        } else {
            self.addMediaToList(anime: anime, type: type)
        }
        self.rootNavigationController?.didChange = true
    }
    
    func updateOrAddMedia(isInList: Bool, manga: Manga?, type: Int) {
        if isInList {
            self.updateMedia(manga: manga, type: type)
        } else {
            self.addMediaToList(manga: manga, type: type)
        }
    }
    
    // Post request to MAL to add the media to list
    func addMediaToList(anime: Anime?, type: Int) {
        guard let id = anime?.series_animedb_id else { return }
        
        malkit.addAnime(id, params:["status": type], completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                DispatchQueue.main.async {
                    self.setAddToListToMove()
                }
            }
        })
    }
    
    func updateMedia(anime: Anime?, type: Int) {
        guard let id = anime?.series_animedb_id else { return }
        
        malkit.updateAnime(id, params:["status": type], completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
        })
    }
    
    func updateMedia(manga: Manga?, type: Int) {
        guard let id = anime?.series_animedb_id else { return }
        
        malkit.updateManga(id, params:["status": type], completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
        })
    }
    
    // Post request to MAL to add the media to list
    func addMediaToList(manga: Manga?, type: Int) {
        guard let id = manga?.series_mangadb_id else { return }
        
        malkit.addManga(id, params:["status": type], completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                DispatchQueue.main.async {
                    self.setAddToListToMove()
                }
            }
        })
    }
    
    func removeMediaFromList(anime: Anime?) {
        guard let id = anime?.series_animedb_id else { return }
        
        malkit.deleteAnime(id, completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                DispatchQueue.main.async {
                    self.addToListButton.setTitle("Add to list", for: UIControlState.normal)
                }
            }
        })
    }
    
    func removeMediaFromList(manga: Manga?) {
        guard let id = manga?.series_mangadb_id else { return }
        
        malkit.deleteManga(id, completionHandler: { (result, status, err) in
            //20 is anime_id
            //result is Bool
            //status is HTTPURLResponse
            //your process
            if (result!) {
                DispatchQueue.main.async {
                    self.addToListButton.setTitle("Add to list", for: UIControlState.normal)
                }
            }
        })
    }
    
    func listContainsMedia(anime: Anime) -> [Anime]? {
        if anime.my_status == nil {
            return nil
        }
        
        if anime.my_status == MiruGlobals.WATCHING_OR_READING {
            return rootNavigationController?.user?.currentlyWatching
        } else if anime.my_status == MiruGlobals.COMPLETED {
            return rootNavigationController?.user?.completedAnime
        } else if anime.my_status == MiruGlobals.ON_HOLD {
            return rootNavigationController?.user?.onHoldAnime
        } else if anime.my_status == MiruGlobals.DROPPED {
            return rootNavigationController?.user?.droppedAnime
        } else {
            return rootNavigationController?.user?.planToWatch
        }
    }
    
    func listContainsMedia(manga: Manga) -> [Manga]? {
        if manga.my_status == nil {
            return nil
        }
        
        if manga.my_status == MiruGlobals.WATCHING_OR_READING {
            return rootNavigationController?.user?.currentlyReading
        } else if manga.my_status == MiruGlobals.COMPLETED {
            return rootNavigationController?.user?.completedManga
        } else if manga.my_status == MiruGlobals.ON_HOLD {
            return rootNavigationController?.user?.onHoldManga
        } else if manga.my_status == MiruGlobals.DROPPED {
            return rootNavigationController?.user?.droppedManga
        } else {
            return rootNavigationController?.user?.planToRead
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

