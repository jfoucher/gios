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
    
    
    var profile: Profile?
}

class ChangeReceiverViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var search: UITextField!
    @IBOutlet weak var topBarHeight: NSLayoutConstraint!
    var request: Request?
    var profiles: [Profile?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 64.0
        self.search.becomeFirstResponder()
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.profiles.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCell", for: indexPath) as! ChangeUserTableViewCell
        if let prof = self.profiles[indexPath[1]] {
            cell.name.text = prof.title!
            prof.getAvatar(imageView: cell.avatar)
            if let time = prof.time {
                let date = Date(timeIntervalSince1970: Double(time))
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "dd/MM/YYYY HH:mm:ss"
                cell.date?.text = dateFormatter.string(from: date)
                
            }
            
            

        }
        
        print(indexPath)
        return cell
    }
    
    @IBAction func searchChanged(_ sender: UITextField) {
        print("change", sender.text)
        if let req = self.request {
            self.request?.cancel()
        }
        let url = String(format:"%@/user,page,group/profile,record/_search?q=title:*%@*&size=10&from=0", "default_data_host".localized(), sender.text ?? "").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        self.request = Request(url: url)
        self.request?.jsonDecodeWithCallback(type: ProfileSearchResponse.self, callback: { error, response in
            print("resp^")
            if let hits = response?.hits {
                if let total = hits.total {
                    if (total > 0) {
                        self.profiles = hits.hits.map { (p) -> Profile? in
                            if let prof = p._source {
                                return prof
                            }
                            return nil
                        }.filter({ (p) -> Bool in
                                return p != nil
                        })
                        
                    } else {
                        self.profiles = []
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
