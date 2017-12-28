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
                setAddToListToMove()
            }
        } else {
            // it is a manga
            let img = imageCache.object(forKey: manga?.series_image! as! NSString)
            Util.setImage(manga: manga, imageViewToSet: mediaImageView, image: img, cache: imageCache)
            
            guard let id = manga?.series_mangadb_id else { return }
            if self.rootNavigationController?.user?.idToManga[id] != nil {
                setAddToListToMove()
            }
        }
    }
    
    func setAddToListToMove() {
        addToListButton.setTitle("Move", for: UIControlState.normal)
    }
    
    @IBAction func addToListButtonPressed(_ sender: Any) {
        let actionController = UIAlertController(title: nil, message: "Add to list", preferredStyle: .actionSheet)
        
        var listWhichContainsMedia: [Any]?
        if manga == nil {
            guard let anime = self.anime else { return }
            listWhichContainsMedia = listContainsMedia(anime: anime)
        } else {
            guard let manga = self.manga else { return }
            listWhichContainsMedia = listContainsMedia(manga: manga)
        }
        
        let currentlyWatchingAction = UIAlertAction(title: "Currently watching", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
            if self.manga == nil {
                self.addMediaToList(anime: self.anime, type: MiruGlobals.WATCHING_OR_READING)
            } else {
                self.addMediaToList(manga: self.manga, type: MiruGlobals.WATCHING_OR_READING)

            }
        })
        
        let completedAction = UIAlertAction(title: "Completed", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.addMediaToList(anime: self.anime, type: MiruGlobals.COMPLETED)
            } else {
                self.addMediaToList(manga: self.manga, type: MiruGlobals.COMPLETED)

            }
        })
        
        let onHoldAction = UIAlertAction(title: "On hold", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.addMediaToList(anime: self.anime, type: MiruGlobals.ON_HOLD)
            } else {
                self.addMediaToList(manga: self.manga, type: MiruGlobals.ON_HOLD)

            }
        })
        
        let droppedAction = UIAlertAction(title: "Dropped", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.addMediaToList(anime: self.anime, type: MiruGlobals.DROPPED)
            } else {
                self.addMediaToList(manga: self.manga, type: MiruGlobals.DROPPED)

            }
        })
        
        let planToWatchAction = UIAlertAction(title: "Plan to watch", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            if self.manga == nil {
                self.addMediaToList(anime: self.anime, type: MiruGlobals.PLAN_TO_WATCH_OR_READ)
            } else {
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
        
        if listWhichContainsMedia != nil {
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
