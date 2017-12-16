//
//  UserAnimeStatisticsTableView.swift
//  Miru
//
//  Created by Angus Yuen on 16/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import Foundation
import UIKit

class UserStatisticsTableView: UITableView {
    @IBOutlet weak var watching: UITableViewCell!
    @IBOutlet weak var completed: UITableViewCell!
    @IBOutlet weak var onHold: UITableViewCell!
    @IBOutlet weak var dropped: UITableViewCell!
    @IBOutlet weak var planToWatch: UITableViewCell!
    @IBOutlet weak var daysSpentWatching: UITableViewCell!
    
    @IBOutlet weak var mangaReading: UITableViewCell!
    @IBOutlet weak var mangaCompleted: UITableViewCell!
    @IBOutlet weak var mangaOnHold: UITableViewCell!
    @IBOutlet weak var mangaDropped: UITableViewCell!
    @IBOutlet weak var mangaPlanToRead: UITableViewCell!
    @IBOutlet weak var daysSpentReading: UITableViewCell!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        watching.detailTextLabel?.text = String(describing: MiruGlobals.user.user_watching!)
        completed.detailTextLabel?.text = String(describing: MiruGlobals.user.user_completed!)
        onHold.detailTextLabel?.text = String(describing: MiruGlobals.user.user_onhold!)
        dropped.detailTextLabel?.text = String(describing: MiruGlobals.user.user_dropped!)
        planToWatch.detailTextLabel?.text = String(describing: MiruGlobals.user.user_plantowatch!)
        daysSpentWatching.detailTextLabel?.text = String(describing: MiruGlobals.user.user_days_spent_watching!)
        
        mangaReading.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_reading!)
        mangaCompleted.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_completed!)
        mangaOnHold.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_onhold!)
        mangaDropped.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_dropped!)
        mangaPlanToRead.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_plantoread!)
        daysSpentReading.detailTextLabel?.text = String(describing: MiruGlobals.user.user_manga_days_spent_reading!)
    }
}
