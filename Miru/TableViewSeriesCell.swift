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

    @IBOutlet weak var episodesWatched: UILabel!
    
    @IBOutlet weak var myScore: UILabel!
    var anime: Anime?
    
    func configureCell(anime: Anime, image: UIImage?, cache: NSCache<NSString, UIImage>){
        self.anime = anime
        
        if image != nil{
            //The image exist so you assign it to your UIImageView
            imageThumbnail.image = image
            print("EXISTS")
        }else{
            print("DOWNLOAD")
            //Create the request to download the image
            if let seriesImage = anime.series_image {
                let url = URL(string: seriesImage)
                
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                    DispatchQueue.main.async {
                        self.imageThumbnail.image = UIImage(data: data!)
                        cache.setObject(self.imageThumbnail.image!, forKey: anime.series_image as! NSString)
                    }
                }
            }
        }
    }
}
