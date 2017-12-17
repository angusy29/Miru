//
//  Manga.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation

class Manga {
    // populated from getList in ListViewController
    var series_mangadb_id: Int?
    var series_title: String?
    var series_synonyms: String?
    var series_type: Int?
    var series_chapters: Int?
    var series_volumes: Int?
    var series_status: Int?
    var series_start: Date?
    var series_end: Date?
    var series_image: String?
    var my_read_chapters: Int?
    var my_read_volumes: Int?
    var my_start_date: Date?
    var my_finish_date: Date?
    var my_score: Int?
    var my_status: Int?
    var my_rereadingg: Int?
    var my_rereading_chap: Int?
    var my_last_updated: Int?
    
    // Populated from search results in browse
    // id (as above)
    // title (as above)
    // english
    // synonyms (as above)
    // chapters (as above)
    // volumes (as above)
    // score
    // type (we'll make it a string)
    // status (we'll make it a string)
    // start date (as above)
    // end date (as above)
    // synopsis
    // image (as above)
    var english: String?
    var mal_score: Double?
    var search_result_type: String?
    var search_result_status: String?
    var synopsis: String?
}
