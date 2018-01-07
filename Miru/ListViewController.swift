//
//  ListViewController.swift
//  Miru
//
//  Created by Angus Yuen on 15/12/17.
//  Copyright © 2017 Angus Yuen. All rights reserved.
//

import EHHorizontalSelectionView
import Foundation
import UIKit

class ListViewController: EpisodeChapterPickerView, EHHorizontalSelectionViewProtocol, XMLParserDelegate, TableViewSeriesCellProtocol {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var horizontalView: EHHorizontalSelectionView!
    
    // @IBOutlet weak var pickerView: UIPickerView!
    // @IBOutlet weak var pickerToolbar: UIToolbar!
        
    // horizontal view states
    var states = [MiruGlobals.WATCHING_OR_READING,
                  MiruGlobals.COMPLETED,
                  MiruGlobals.ON_HOLD,
                  MiruGlobals.DROPPED,
                  MiruGlobals.PLAN_TO_WATCH_OR_READ]
    var selectedState = MiruGlobals.WATCHING_OR_READING
    
    // picker view selected item
    // var selectedPickerViewItem: Int?
    
    // XML parsing variables
    var currentXMLElement: String?   // xml element we are looking at in XML file eg. <my_status>
    var type: String?
    
    // picker view data source
    /*var scores = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var scoreString = ["-", "(1) Appalling", "(2) Horrible", "(3) Very bad", "(4) Bad", "(5) Average", "(6) Fine", "(7) Good", "(8) Very good", "(9) Great", "(10) Masterpiece"]
    var episodesOrChapters = [Int]()*/
    
    // Used for changing scores for the anime/manga
    // this is actually so bad practice.....
    /*var anime: Anime?
    var manga: Manga?
    var cell: TableViewSeriesCell?      // cell to modify
    var pickerViewModifyType: Int?   // "score" or "episode", denotes which one to change in pickerview*/
    
    var rootNavigationController: RootNavigationController?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (self.rootNavigationController?.didChange)! {
            print("DID CHANGE")
            refresh()
            self.rootNavigationController?.didChange = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD")
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.rootNavigationController = self.navigationController as? RootNavigationController
        
        // horizontal view initialise
        self.horizontalView.delegate = self
        EHHorizontalLineViewCell.updateFont(UIFont.systemFont(ofSize: 14))
        EHHorizontalLineViewCell.updateFontMedium(UIFont.boldSystemFont(ofSize: 16))
        EHHorizontalLineViewCell.updateColorHeight(2)
        
        // refresh initialise
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching data from myanimelist.net")
        tableView.refreshControl = refreshControl

        hidePickerView()
    }
    
    @objc func refreshList(refreshControl: UIRefreshControl) {
        refresh()
        // somewhere in your code you might need to call:
        refreshControl.endRefreshing()
    }
    
    func refresh() {
        guard let type = self.type else { return }
        
        if type == "anime" {
            rootNavigationController?.user?.idToAnime.removeAll()
            rootNavigationController?.user?.currentlyWatching.removeAll()
            rootNavigationController?.user?.completedAnime.removeAll()
            rootNavigationController?.user?.onHoldAnime.removeAll()
            rootNavigationController?.user?.droppedAnime.removeAll()
            rootNavigationController?.user?.planToWatch.removeAll()
        } else {
            rootNavigationController?.user?.idToManga.removeAll()
            rootNavigationController?.user?.currentlyReading.removeAll()
            rootNavigationController?.user?.completedManga.removeAll()
            rootNavigationController?.user?.onHoldManga.removeAll()
            rootNavigationController?.user?.droppedManga.removeAll()
            rootNavigationController?.user?.planToRead.removeAll()
        }
        
        getList(type: type)
        sortMedia(type: type)
        tableView.reloadData()
    }
    
    func sortMedia(type: String) {
        if type == "anime" {
            guard let currentlyWatching = self.rootNavigationController?.user?.currentlyWatching else { return }
            guard let completedAnime = self.rootNavigationController?.user?.completedAnime else { return }
            guard let onHoldAnime = self.rootNavigationController?.user?.onHoldAnime else { return }
            guard let droppedAnime = self.rootNavigationController?.user?.droppedAnime else { return }
            guard let planToWatch = self.rootNavigationController?.user?.planToWatch else { return }
            
            // sort by alphabetical order
            self.rootNavigationController?.user?.currentlyWatching = currentlyWatching.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.completedAnime = completedAnime.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.onHoldAnime = onHoldAnime.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.droppedAnime = droppedAnime.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.planToWatch = planToWatch.sorted(by: { $0.series_title! < $1.series_title! })
        } else {
            guard let currentlyReading = self.rootNavigationController?.user?.currentlyReading else { return }
            guard let completedManga = self.rootNavigationController?.user?.completedManga else { return }
            guard let onHoldManga = self.rootNavigationController?.user?.onHoldManga else { return }
            guard let droppedManga = self.rootNavigationController?.user?.droppedManga else { return }
            guard let planToRead = self.rootNavigationController?.user?.planToRead else { return }
            
            // sort by alphabetical order
            self.rootNavigationController?.user?.currentlyReading = currentlyReading.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.completedManga = completedManga.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.onHoldManga = onHoldManga.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.droppedManga = droppedManga.sorted(by: { $0.series_title! < $1.series_title! })
            self.rootNavigationController?.user?.planToRead = planToRead.sorted(by: { $0.series_title! < $1.series_title! })
        }
    }
    
    // Get list for that type
    func getList(type: String) {
        guard let username = rootNavigationController?.user?.user_name else { return }
        self.type = type
        let url = URL(string: "https://myanimelist.net/malappinfo.php?u=" + username + "&status=all&type=" + type)
        
        let sem = DispatchSemaphore.init(value: 0)
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            // print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
            if let data = data {
                let parser = XMLParser(data: data)
                parser.delegate = self
                parser.parse()
                sem.signal()
            }
            }.resume()
        
        sem.wait()
    }
    
    // EHHorizontal Protocol
    func horizontalSelection(_ selectionView: EHHorizontalSelectionView, didSelectObjectAt index: UInt) {
        self.selectedState = states[Int(index)]
        self.tableView.reloadData()
    }
    
    func numberOfItems(inHorizontalSelection hSelView: EHHorizontalSelectionView) -> UInt {
        return UInt(states.count)
    }
    
    func titleForItem(at index: UInt, forHorisontalSelection hSelView: EHHorizontalSelectionView) -> String? {
        if self.states[Int(index)] == MiruGlobals.WATCHING_OR_READING {
            return "Currently watching"
        } else if self.states[Int(index)] == MiruGlobals.COMPLETED {
            return "Completed"
        } else if self.states[Int(index)] == MiruGlobals.ON_HOLD {
            return "On hold"
        } else if self.states[Int(index)] == MiruGlobals.DROPPED {
            return "Dropped"
        } else {
            return "Plan to watch"
        }
    }
    
    func isUpdating() {
        Util.showLoading(vc: self, message: "Updating...")
    }
    
    func finishUpdating() {
        Util.dismissLoading(vc: self)
    }
}
