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

class ListViewController: UIViewController, EHHorizontalSelectionViewProtocol, XMLParserDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var horizontalView: EHHorizontalSelectionView!
    
    var states = [MiruGlobals.WATCHING_OR_READING, MiruGlobals.COMPLETED, MiruGlobals.ON_HOLD, MiruGlobals.DROPPED, MiruGlobals.PLAN_TO_WATCH_OR_READ]
    var selectedState = MiruGlobals.WATCHING_OR_READING
    
    // cache for images
    var imageCache = NSCache<NSString, UIImage>()
    
    // XML parsing variables
    var currentXMLElement: String?   // xml element we are looking at in XML file eg. <my_status>
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.horizontalView.delegate = self
        EHHorizontalLineViewCell.updateFont(UIFont.systemFont(ofSize: 14))
        EHHorizontalLineViewCell.updateFontMedium(UIFont.boldSystemFont(ofSize: 16))
        EHHorizontalLineViewCell.updateColorHeight(2)
    }
    
    // Get list for that type
    func getList(type: String) {
        guard let username = MiruGlobals.username else { return }
        let url = URL(string: "https://myanimelist.net/malappinfo.php?u=" + username + "&status=all&type=" + type)
        
        let sem = DispatchSemaphore.init(value: 0)
        URLSession.shared.dataTask(with: url!) {(data, response, error) in
            print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue))
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
}
