//
//  ChangeReceiverViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 03/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit

class ChangeUserTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var endResults: UILabel!
    
    var profile: Profile?
}

class ChangeReceiverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    var request: Request?
    var profiles: [Profile?] = []
    var page: Int = 0
    var end: Bool = false
    weak var profileSelectedDelegate: ReceiverChangedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 64.0
        self.search.becomeFirstResponder()
        self.search.placeholder = "search_placeholder".localized()
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            print("found")
            self.topBarHeight.constant = navigationController.navigationBar.frame.height
            self.view.layoutIfNeeded()
        }

        // get all members
        //https://g1.jfoucher.com/wot/lookup/jon
        //https://g1.data.duniter.fr/user,page,group/profile,record/_search?q=title:jonathan
        // https://g1.data.duniter.fr/user,page,group/profile,record/_search?q=title:*jo*&size=100&from=0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! ChangeUserTableViewCell
        print("selected", indexPath)
        if let prof = cell.profile {
            self.profileSelectedDelegate?.receiverChanged(receiver: prof)
            self.dismiss(animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profiles.count + 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print(indexPath.row, self.end)

        
        if (indexPath.count > 0 && self.profiles.count > indexPath.row) {
            if let prof = self.profiles[indexPath.row] {
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserPrototypeCell", for: indexPath) as! ChangeUserTableViewCell
                cell.profile = prof
                cell.name.text = prof.title!
                prof.getAvatar(imageView: cell.avatar)
                if let time = prof.time {
                    let date = Date(timeIntervalSince1970: Double(time))
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = NSLocale.current
                    dateFormatter.dateFormat = "dd/MM/YYYY HH:mm:ss"
                    cell.date?.text = dateFormatter.string(from: date)
                }
                return cell
            }
        }
        
        
        
        if (indexPath.row == self.profiles.count && self.end == false && self.profiles.count > 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingCell", for: indexPath)
            self.page += 1
            self.loadPage(search: self.search.text ?? "")
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "EndCell", for: indexPath) as! ChangeUserTableViewCell
        cell.endResults.text = "end_results".localized()
        return cell
    }
    
    @IBAction func searchChanged(_ sender: UITextField) {
        print("change", sender.text)
        self.page = 0
        self.end = false
        self.profiles = []
        if let req = self.request {
            req.cancel()
        }
        self.loadPage(search: sender.text ?? "")
    }
    
    func loadPage(search: String) {
        let count = 20
        let url = String(format:"%@/user,page,group/profile,record/_search?q=title:*%@*&size=%d&from=%d", "default_data_host".localized(), search, count, self.page * count).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        print(url)
        self.request = Request(url: url)
        self.request?.jsonDecodeWithCallback(type: ProfileSearchResponse.self, callback: { error, response in
            self.request = nil
            self.end = true
            if let hits = response?.hits {
                if let total = hits.total {
                    if (total > 0 && hits.hits.count > 0) {
                        let newProfiles = hits.hits.map { (p) -> Profile? in
                            if let prof = p._source {
                                return prof
                            }
                            return nil
                            }.filter({ (p) -> Bool in
                                return p != nil
                            })
        
                        self.profiles.append(contentsOf: newProfiles)
                        print("total", total)
                        self.end = false
                        
                    }
                }
            }
            DispatchQueue.main.async { self.tableView?.reloadData() }
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
