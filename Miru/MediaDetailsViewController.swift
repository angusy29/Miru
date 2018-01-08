//
//  MediaDetailsViewController.swift
//  Miru
//
//  Created by Angus Yuen on 27/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

/*
 * Only requires anime/manga object with title, image, id for this ViewController to work
 */
class MediaDetailsViewController: EpisodeChapterPickerView, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mediaNameLabel: UILabel!
    
    @IBOutlet weak var mediaImageView: UIImageView!
    
    @IBOutlet weak var addToListButton: UIButton!
    
    @IBOutlet weak var synopsisLabel: UILabel!
    @IBOutlet weak var malScoreLabel: UILabel!
    
    @IBOutlet weak var rankedLabel: UILabel!
    
    @IBOutlet weak var popularityLabel: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        hidePickerView()
        
        if manga == nil {
            // it is anime
            let img = rootNavigationController?.imageCache.object(forKey: anime?.series_image! as! NSString)
            Util.setImage(anime: anime, imageViewToSet: mediaImageView, image: img, cache: (rootNavigationController?.imageCache)!)
            
            guard let id = anime?.series_animedb_id else { return }
            print(id)
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
            let cacheObj = self.manga == nil ? self.rootNavigationController?.mediaDetailsCache.object(forKey: "anime" + String(describing: (self.anime?.series_animedb_id)!) as NSString) : self.rootNavigationController?.mediaDetailsCache.object(forKey: "manga" + String(describing: (self.manga?.series_mangadb_id)!) as NSString)
            let type = self.manga == nil ? "anime" : "manga"
            self.getDetails(cacheObj: cacheObj, type: type)
        }
    }
    
    func getDetails(cacheObj: MediaDetails?, type: String) {
        if cacheObj != nil {
            print("CACHED")
            self.synopsisLabel.text = String(describing: (cacheObj?.synopsis)!)
            self.malScoreLabel.text = String(describing: (cacheObj?.malScore)!)
            self.rankedLabel.text = String(describing: (cacheObj?.ranked)!)
            self.popularityLabel.text = String(describing: (cacheObj?.popularity)!)
            return
        }
        
        
        let id = manga == nil ? (anime?.series_animedb_id)! : (manga?.series_mangadb_id)!
        let url = manga == nil ? URL(string: "https://myanimelist.net/anime/" + String(describing: id))! :
            URL(string: "https://myanimelist.net/manga/" + String(describing: id))!
        
        print(url)
        var synopsis: String?
        var malScore: String?
        var ranked: String?
        var popularity: String?
        
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
            ranked = string?.slice(from: "<span class=\"dark_text\">Ranked:</span>", to: "<sup>")
            popularity = string?.slice(from: "<span class=\"dark_text\">Popularity:</span>", to: "\n</div>")
            sem.signal()
        }.resume()
        
        sem.wait()
        
        guard let unwrap = synopsis else { return }
        guard let unwrapScore = malScore else { return }
        guard let unwrapRanked = ranked else { return }
        guard let unwrapPopularity = popularity else { return }
        do {
            let syn = try! NSAttributedString(data: unwrap.data(using: String.Encoding.utf8)!,
                                                             options: [.documentType: NSAttributedString.DocumentType.html,
                                                                       .characterEncoding: String.Encoding.utf8.rawValue],
                                                             documentAttributes: nil)
            
            let score = try! NSAttributedString(data: unwrapScore.data(using: String.Encoding.utf8)!,
                                                options: [.documentType: NSAttributedString.DocumentType.html,
                                                          .characterEncoding: String.Encoding.utf8.rawValue],
                                                documentAttributes: nil)
            
            let ranked = try! NSAttributedString(data: unwrapRanked.data(using: String.Encoding.utf8)!,
                                                options: [.documentType: NSAttributedString.DocumentType.html,
                                                          .characterEncoding: String.Encoding.utf8.rawValue],
                                                documentAttributes: nil)
            
            let popularity = try! NSAttributedString(data: unwrapPopularity.data(using: String.Encoding.utf8)!,
                                                     options: [.documentType: NSAttributedString.DocumentType.html,
                                                               .characterEncoding: String.Encoding.utf8.rawValue],
                                                     documentAttributes: nil)
            
            let newMediaObj = MediaDetails(synopsis: syn.string, malScore: score.string, ranked: ranked.string, popularity: popularity.string)
            self.rootNavigationController?.mediaDetailsCache.setObject(newMediaObj, forKey: type + String(describing: id) as NSString)
            
            self.synopsisLabel.text = syn.string
            self.malScoreLabel.text = score.string
            self.rankedLabel.text = ranked.string
            self.popularityLabel.text = popularity.string
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
        Util.showLoading(vc: self, message: "Updating...")
        if isInList {
            self.updateMedia(anime: anime, type: type)
        } else {
            self.addMediaToList(anime: anime, type: type)
        }
        Util.dismissLoading(vc: self)
        self.rootNavigationController?.didChange = true
    }
    
    func updateOrAddMedia(isInList: Bool, manga: Manga?, type: Int) {
        Util.showLoading(vc: self, message: "Updating...")
        if isInList {
            self.updateMedia(manga: manga, type: type)
        } else {
            self.addMediaToList(manga: manga, type: type)
        }
        Util.dismissLoading(vc: self)
        self.rootNavigationController?.didChange = true
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
    
    // TableView protocols
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: "reuseIdentifier")
        }
        
        if indexPath.row == 0 {
            cell?.textLabel?.text = "Episode"
            cell?.detailTextLabel?.text = "0"
        } else {
            cell?.textLabel?.text = "My score"
            cell?.detailTextLabel?.text = "-"
        }
        
        // set episodes and my score
        if manga == nil {
            // is an anime
            let foundAnime = self.rootNavigationController?.user?.idToAnime[(self.anime?.series_animedb_id)!]
            if foundAnime != nil {
                if indexPath.row == 0 {
                    if foundAnime?.my_watched_episodes == nil {
                        cell?.detailTextLabel?.text = "0/" + String(describing: (foundAnime?.series_episodes)!)
                    } else {
                        cell?.detailTextLabel?.text = String(describing: (foundAnime?.my_watched_episodes)!) + "/" + String(describing: (foundAnime?.series_episodes)!)
                    }
                } else {
                    if foundAnime?.my_score != 0 {
                        cell?.detailTextLabel?.text = String(describing: (foundAnime?.my_score)!)
                    }
                }
            }
        } else {
            let foundManga = self.rootNavigationController?.user?.idToManga[(self.manga?.series_mangadb_id)!]
            if foundManga != nil {
                if indexPath.row == 0 {
                    if foundManga?.my_read_chapters == nil {
                        cell?.detailTextLabel?.text = "0/" + String(describing: (foundManga?.series_chapters)!)
                    } else {
                        cell?.detailTextLabel?.text = String(describing: (foundManga?.my_read_chapters)!) + "/" + String(describing: (foundManga?.series_chapters)!)
                    }
                } else {
                    if foundManga?.my_score != 0 {
                        cell?.detailTextLabel?.text = String(describing: (foundManga?.my_score)!)
                    }
                }
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("HELLO")
        if indexPath.row == 0 {
            // episode
            if manga == nil {
                guard let anime = self.anime else { return }
                showPickerView(anime: anime, cell: self.tableView.cellForRow(at: indexPath)!, type: MiruGlobals.CHANGE_EPISODE_OR_CHAPTER)
            } else {
                guard let manga = self.manga else { return }
                showPickerView(manga: manga, cell: self.tableView.cellForRow(at: indexPath)!, type: MiruGlobals.CHANGE_EPISODE_OR_CHAPTER)
            }
        } else {
            // my score
            // episode
            if manga == nil {
                guard let anime = self.anime else { return }
                showPickerView(anime: anime, cell: self.tableView.cellForRow(at: indexPath)!, type: MiruGlobals.CHANGE_SCORE)
            } else {
                guard let manga = self.manga else { return }
                showPickerView(manga: manga, cell: self.tableView.cellForRow(at: indexPath)!, type: MiruGlobals.CHANGE_SCORE)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

