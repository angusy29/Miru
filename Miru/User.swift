//
//  User.swift
//  Miru
//
//  Created by Angus Yuen on 16/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation

class User {
    // dp is located at "https://myanimelist.cdn-dena.com/images/userimages/" + user_id + ".jpg"
    var user_id: Int?
    var user_picture: String?
    var user_name: String?
    var user_watching: Int?
    var user_completed: Int?
    var user_onhold: Int?
    var user_dropped: Int?
    var user_plantowatch: Int?
    var user_days_spent_watching: Double?
    
    var user_manga_reading: Int?
    var user_manga_completed: Int?
    var user_manga_onhold: Int?
    var user_manga_dropped: Int?
    var user_manga_plantoread: Int?
    var user_manga_days_spent_reading: Double? // API calls it user_days_spent_watching
}
