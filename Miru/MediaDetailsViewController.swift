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
    
    var anime: Anime?
    var manga: Manga?
    var rootNavigationController: RootNavigationController?
    
    var isInList = false
    
    var imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.prefersLargeTitles = false
        self.rootNavigationController = self.navigationController as? RootNavigationController
        
        self.mediaNameLabel.text = manga == nil ? anime?.series_title : manga?.series_title
        //self.mediaNameLabel.lineBreakMode = .byWordWrapping
        
        addToListButton.layer.cornerRadius = 8
        
        if manga == nil {
            // it is anime
            let img = imageCache.object(forKey: anime?.series_image! as! NSString)
            Util.setImage(anime: anime, imageViewToSet: mediaImageView, image: img, cache: imageCache)
            
            guard let id = anime?.series_animedb_id else { return }
            if self.rootNavigationController?.user?.idToAnime[id] != nil {
                isInList = true
                setAddToListToMove()
            }
        } else {
            // it is a manga
            let img = imageCache.object(forKey: manga?.series_image! as! NSString)
            Util.setImage(manga: manga, imageViewToSet: mediaImageView, image: img, cache: imageCache)
            
            guard let id = manga?.series_mangadb_id else { return }
            if self.rootNavigationController?.user?.idToManga[id] != nil {
                isInList = true
                setAddToListToMove()
            }
        }
    }
    
    func setAddToListToMove() {
        addToListButton.setTitle("Move", for: UIControlState.normal)
    }
    
    @IBAction func addToListButtonPressed(_ sender: Any) {
        let actionController = UIAlertController(title: nil, message: "Add to list", preferredStyle: .actionSheet)
        
        let currentlyWatchingAction = UIAlertAction(title: "Currently watching", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
            if self.manga == nil {
                // guard let unwrapAnime = self.anime else { return }
                // self.rootNavigationController?.user?.currentlyWatching.append(unwrapAnime)
                self.addMediaToList(anime: self.anime, type: MiruGlobals.WATCHING_OR_READING)
            } else {
                // guard let unwrapManga = self.manga else { return }
                // self.rootNavigationController?.user?.currentlyReading.append(unwrapManga)
                self.addMediaToList(manga: self.manga, type: MiruGlobals.WATCHING_OR_READING)

            }
        })
        
        let completedAction = UIAlertAction(title: "Completed", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some destructive action here.
            if self.manga == nil {
                // guard let unwrapAnime = self.anime else { return }
                // self.rootNavigationController?.user?.completedAnime.append(unwrapAnime)
                self.addMediaToList(anime: self.anime, type: MiruGlobals.COMPLETED)
            } else {
                // guard let unwrapManga = self.manga else { return }
                // self.rootNavigationController?.user?.completedManga.append(unwrapManga)
                self.addMediaToList(manga: self.manga, type: MiruGlobals.COMPLETED)

            }
        })
        
        let onHoldAction = UIAlertAction(title: "On hold", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                // guard let unwrapAnime = self.anime else { return }
                // self.rootNavigationController?.user?.onHoldAnime.append(unwrapAnime)
                self.addMediaToList(anime: self.anime, type: MiruGlobals.ON_HOLD)
            } else {
                // guard let unwrapManga = self.manga else { return }
                // self.rootNavigationController?.user?.onHoldManga.append(unwrapManga)
                self.addMediaToList(manga: self.manga, type: MiruGlobals.ON_HOLD)

            }
        })
        
        let droppedAction = UIAlertAction(title: "Dropped", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                // guard let unwrapAnime = self.anime else { return }
                // self.rootNavigationController?.user?.droppedAnime.append(unwrapAnime)
                self.addMediaToList(anime: self.anime, type: MiruGlobals.DROPPED)
            } else {
                // guard let unwrapManga = self.manga else { return }
                // self.rootNavigationController?.user?.droppedManga.append(unwrapManga)
                self.addMediaToList(manga: self.manga, type: MiruGlobals.DROPPED)

            }
        })
        
        let planToWatchAction = UIAlertAction(title: "Plan to watch", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                // guard let unwrapAnime = self.anime else { return }
                // self.rootNavigationController?.user?.planToWatch.append(unwrapAnime)
                self.addMediaToList(anime: self.anime, type: MiruGlobals.PLAN_TO_WATCH_OR_READ)
            } else {
                // guard let unwrapManga = self.manga else { return }
                // self.rootNavigationController?.user?.planToRead.append(unwrapManga)
                self.addMediaToList(manga: self.manga, type: MiruGlobals.PLAN_TO_WATCH_OR_READ)

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
                    self.isInList = true
                }
            }
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
                    self.isInList = true
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
                    self.isInList = false
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
                    self.isInList = false
                }
            }
        })
    }
    
    // Find the list which contains the media
    func findListContainsMedia() -> [Any]? {
        if manga == nil {
            // check anime
            if (rootNavigationController?.user?.currentlyWatching.contains(where: { $0.series_animedb_id == anime?.series_animedb_id }))! {
                return rootNavigationController?.user?.currentlyWatching
            }
            
            if (rootNavigationController?.user?.completedAnime.contains(where: { $0.series_animedb_id == anime?.series_animedb_id }))! {
                return rootNavigationController?.user?.completedAnime
            }
            
            if (rootNavigationController?.user?.onHoldAnime.contains(where: { $0.series_animedb_id == anime?.series_animedb_id }))! {
                return rootNavigationController?.user?.onHoldAnime
            }
            
            if (rootNavigationController?.user?.droppedAnime.contains(where: { $0.series_animedb_id == anime?.series_animedb_id }))! {
                return rootNavigationController?.user?.droppedAnime
            }
            
            if (rootNavigationController?.user?.planToWatch.contains(where: { $0.series_animedb_id == anime?.series_animedb_id }))! {
                return rootNavigationController?.user?.planToWatch
            }
        } else {
            // check manga
            if (rootNavigationController?.user?.currentlyReading.contains(where: { $0.series_mangadb_id == manga?.series_mangadb_id }))! {
                return rootNavigationController?.user?.currentlyReading
            }
            
            if (rootNavigationController?.user?.completedManga.contains(where: { $0.series_mangadb_id == manga?.series_mangadb_id }))! {
                return rootNavigationController?.user?.completedManga
            }
            
            if (rootNavigationController?.user?.onHoldManga.contains(where: { $0.series_mangadb_id == manga?.series_mangadb_id }))! {
                return rootNavigationController?.user?.onHoldManga
            }
            
            if (rootNavigationController?.user?.droppedManga.contains(where: { $0.series_mangadb_id == manga?.series_mangadb_id }))! {
                return rootNavigationController?.user?.droppedManga
            }
            
            if (rootNavigationController?.user?.planToRead.contains(where: { $0.series_mangadb_id == manga?.series_mangadb_id }))! {
                return rootNavigationController?.user?.planToRead
            }
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
