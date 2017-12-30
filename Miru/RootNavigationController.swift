//
//  RootNavigationController.swift
//  Miru
//
//  Created by Angus Yuen on 28/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

/*
 * RootNavigationController is the root controller of all viewcontrollers
 * Contains the user
 */
class RootNavigationController: UINavigationController {
    var user: User?
    var didChange = false
    var imageCache = NSCache<NSString, UIImage>()       // map of image links to the actual image
    var webscrapeCache = NSCache<NSString, WebscrapeMedia>()   // map of "anime|manga"+id to synopsis
}
