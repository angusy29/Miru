//
//  MiruGlobals.swift
//  Miru
//
//  Created by Angus Yuen on 14/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation

class MiruGlobals {
    static var username: String?
    
    // my list statuses
    static var WATCHING_OR_READING = 1
    static var COMPLETED = 2
    static var ON_HOLD = 3
    static var DROPPED = 4
    static var PLAN_TO_WATCH_OR_READ = 6
    
    // anime or manga status
    static var CURRENTLY_ONGOING = 1
    static var FINISHED_AIRING = 2
    static var NOT_YET_RELEASED = 3
    
    // picker view modify type
    static var CHANGE_SCORE = 0
    static var CHANGE_EPISODE_OR_CHAPTER = 1
}
