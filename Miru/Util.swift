//
//  Util.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func setBottomBorder() {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect.init(x: 0.0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = UIColor.white.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(bottomBorder)
    }
}

class Util {
    
    class func setImage(anime: Anime?, imageViewToSet: UIImageView, image: UIImage?, cache: NSCache<NSString, UIImage>){
        if image != nil{
            //The image exist so you assign it to your UIImageView
            imageViewToSet.image = image
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
                            imageViewToSet.image = UIImage(data: unwrapData)
                            cache.setObject(imageViewToSet.image!, forKey: anime?.series_image! as! NSString)
                        }
                    }
                }
            }
        }
    }
    
    class func setImage(manga: Manga?, imageViewToSet: UIImageView, image: UIImage?, cache: NSCache<NSString, UIImage>){
        if image != nil{
            //The image exist so you assign it to your UIImageView
            imageViewToSet.image = image
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
                            imageViewToSet.image = UIImage(data: unwrapData)
                            cache.setObject(imageViewToSet.image!, forKey: manga?.series_image! as! NSString)
                        }
                    }
                }
            }
        }
    }
}
