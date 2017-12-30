//
//  WebscrapeMedia.swift
//  Miru
//
//  Created by Angus Yuen on 30/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation

class WebscrapeMedia {
    var synopsis: String?
    var malScore: String?
    
    init(synopsis: String, malScore: String) {
        self.synopsis = synopsis
        self.malScore = malScore
    }
}
