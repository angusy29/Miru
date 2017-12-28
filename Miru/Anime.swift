//
//  Anime.swift
//  Miru
//
//  Created by Angus Yuen on 13/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation

class Anime {
    // these are for anime list XML fields
    var series_animedb_id: Int?
    var series_title: String?
    var series_synonyms: [String]?
    var series_type: Int?
    var series_episodes: Int?
    var series_status: Int?
    var series_image: String?
    var series_start: Date?
    var series_end: Date?
    var my_watched_episodes: Int?
    var my_start_date: Date?
    var my_finish_date: Date?
    var my_score: Int?
    var my_status: Int?     // 1, 2, 3, 4, 6
    var my_rewatching: Int?
    var my_rewatching_ep: Int?
    var my_last_updated: Int?
    
    // search result xml has...
    // id (as above)
    // title (as above)
    // english (merge into synonyms?)
    // synonyms (as above)
    // episodes (as above)
    // score (this is MAL score... will need a new field)
    // type (string) (find the relationship with above)
    // status (string) (find relationship with above)
    // start_date (as above)
    // end_date (as above)
    // synopsis (new field)
    // image (as above)
    
    // these are for search result api XML fields
    var english: String?
    var mal_score: Double?
    var synopsis: String?
    var search_result_type: String?
    var search_result_status: String?
}
