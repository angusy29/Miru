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
    
    var imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewDidLoad() {
        self.mediaNameLabel.text = manga == nil ? anime?.series_title : manga?.series_title
        //self.mediaNameLabel.lineBreakMode = .byWordWrapping
        
        if manga == nil {
            let img = imageCache.object(forKey: anime?.series_image! as! NSString)
            self.setImage(anime: anime, image: img, cache: imageCache)
        } else {
            let img = imageCache.object(forKey: manga?.series_image! as! NSString)
            self.setImage(manga: manga, image: img, cache: imageCache)
        }
        
        addToListButton.layer.cornerRadius = 8
    }
    
    func setImage(anime: Anime?, image: UIImage?, cache: NSCache<NSString, UIImage>){
        self.anime = anime
        
        if image != nil{
            //The image exist so you assign it to your UIImageView
            self.mediaImageView.image = image
        } else {
            //Create the request to download the image
            if let seriesImage = anime?.series_image {
                let url = URL(string: seriesImage)
                if url == nil {
                    return
                }
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        if let unwrapData = data {
                            self.mediaImageView.image = UIImage(data: unwrapData)
                            cache.setObject(self.mediaImageView.image!, forKey: anime?.series_image! as! NSString)
                        }
                    }
                }
            }
        }
    }
    
    func setImage(manga: Manga?, image: UIImage?, cache: NSCache<NSString, UIImage>){
        self.manga = manga
        
        if image != nil{
            //The image exist so you assign it to your UIImageView
            self.mediaImageView.image = image
        } else {
            //Create the request to download the image
            if let seriesImage = manga?.series_image {
                let url = URL(string: seriesImage)
                if url == nil {
                    return
                }
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        if let unwrapData = data {
                            self.mediaImageView.image = UIImage(data: unwrapData)
                            cache.setObject(self.mediaImageView.image!, forKey: manga?.series_image! as! NSString)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func addToListButtonPressed(_ sender: Any) {
        let actionController = UIAlertController(title: nil, message: "Add to list", preferredStyle: .actionSheet)
        
        let currentlyWatchingAction = UIAlertAction(title: "Currently watching", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some action here.
        })
        
        let completedAction = UIAlertAction(title: "Completed", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //  Do some destructive action here.
        })
        
        let onHoldAction = UIAlertAction(title: "On hold", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            
        })
        
        let droppedAction = UIAlertAction(title: "Dropped", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            
        })
        
        let planToWatchAction = UIAlertAction(title: "Plan to watch", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            
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
        
        self.present(actionController, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
