//
//  MediaDetails.swift
//  Miru
//
//  Created by Angus Yuen on 30/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation

/*
 * Serves as the details object for an anime or manga
 * Made this class because Anime and Manga were dedicated to API results
 * The API sucks so this contains results of web scraping the website
 */
class MediaDetails {
    var synopsis: String?
    var malScore: String?
    
    init(synopsis: String, malScore: String) {
        self.synopsis = synopsis
        self.malScore = malScore
    }
}
