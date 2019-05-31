//
//  ProfileViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit
import Sodium
import CryptoSwift

struct TransactionSection : Comparable {
    var type : String
    var transactions : [ParsedTransaction]
    
    static func < (lhs: TransactionSection, rhs: TransactionSection) -> Bool {
        return lhs.type < rhs.type
    }
    
    static func == (lhs: TransactionSection, rhs: TransactionSection) -> Bool {
        return lhs.type == rhs.type
    }
}

class TransactionTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var publickey: UILabel!
    @IBOutlet weak var avatar: UIImageView!
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    weak var delegate: LogoutDelegate?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var publicKey: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var keyImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    var profile: Profile?
    var sections: [TransactionSection]? = []
    
    @IBOutlet weak var avatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let profile = self.profile {
            self.name.text = profile.title != nil ? profile.title : profile.uid
            self.balance.text = "balance_label".localized()
            self.publicKey.text = profile.issuer
            self.getAvatar(pubKey: profile.issuer)
            self.keyImage.tintColor = .white
            self.keyImage.image = UIImage(named: "key")?.withRenderingMode(.alwaysTemplate)
            
            self.getBalance(pubKey: profile.issuer, callback: { str in
                DispatchQueue.main.async {
                    self.balance.text = str
                }
            })
            
            // now we can get the history of transactions and show them
            
            self.getTransactions(pubKey: profile.issuer)
        }
        
        // make request to
        // https://g1.nordstrom.duniter.org/tx/sources/EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq
        // to get account total. We probably have to add all the sources
        // RESPONSE
//        {
//            "currency": "g1",
//            "pubkey": "EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq",
//            "sources": [
//            {
//            "type": "T",
//            "noffset": 0,
//            "identifier": "A888D00A7085DD1EEBABCD55A9B2F189FBD7E838E3776DB175857758FCE8AFB2",
//            "amount": 500,
//            "base": 0,
//            "conditions": "SIG(EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq)"
//            }
//            ]
//        }
        
        

    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = self.sections {
            //Only display sections with transactions
            let sects = sections.filter { (section) -> Bool in
                section.transactions.count > 0
            }
            return sects.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = self.sections {
            let sects = sections.filter { (section) -> Bool in
                section.transactions.count > 0
            }
            
            return sects[section].transactions.count
            
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCell", for: indexPath) as! TransactionTableViewCell

        // [0, 0]
        if let sections = self.sections {
            let sects = sections.filter { (section) -> Bool in
                section.transactions.count > 0
            }
            
            let transaction = sects[indexPath[0]].transactions[indexPath[1]]

            let pk = transaction.pubKey
            cell.name?.text = ""
            cell.publickey?.text = pk
            let imgurl = String(format: "%@/user/profile/%@/_image/avatar.png", "default_data_host".localized(), pk)
            let defaultAvatarUrl = String(format: "https://api.adorable.io/avatars/%d/%@", Int(128 * UIScreen.main.scale), pk)
            
            cell.avatar?.loadImageUsingCache(withUrl: imgurl, fail: { error in
                cell.avatar?.loadImageUsingCache(withUrl: defaultAvatarUrl, fail: nil)
            })
            
            // This is two requests per cell, maybe we should get all the users and work with that instead
            Profile.getRequirements(publicKey: pk, callback: { identity in
                if let ident = identity {
                    Profile.getProfile(publicKey: pk, identity: ident, callback: { profile in
                        if let prof = profile {
                            DispatchQueue.main.async {
                                cell.name?.text = prof.title != nil ? prof.title : prof.uid
                            }
                        }
                    })
                }
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sections = self.sections {
            let sects = sections.filter { (section) -> Bool in
                section.transactions.count > 0
            }
            
            return sects[section].type.localized()
        }
        
        
        return ""
    }
    

    func getTransactions(pubKey: String) {
        //https://g1.nordstrom.duniter.org/tx/history/EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq
        let url = String(format: "%@/tx/history/%@", "default_node".localized(), pubKey)
        print(url)
        let transactionRequest = Request(url: url)
        
        transactionRequest.jsonDecodeWithCallback(type: TransactionResponse.self, callback: { transactionResponse in
            
            if let history = transactionResponse.history {
                self.sections = [
                    TransactionSection.init(type: "sent", transactions: history.sent.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }),
                     TransactionSection.init(type: "received", transactions: history.received.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }),
                      TransactionSection.init(type: "sending", transactions: history.sending.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }),
                       TransactionSection.init(type: "receiving", transactions: history.receiving.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }),
                ]
                
                DispatchQueue.main.async { self.tableView?.reloadData() }
            }
            
            
        })
    }
    
    func getAvatar(pubKey: String) {
        let imgurl = String(format: "%@/user/profile/%@/_image/avatar.png", "default_data_host".localized(), pubKey)
        
        self.avatar.layer.borderWidth = 1
        self.avatar.layer.masksToBounds = false
        self.avatar.layer.borderColor = UIColor.black.cgColor
        self.avatar.layer.cornerRadius = avatar.frame.width/2
        self.avatar.clipsToBounds = true
        
        self.avatar.loadImageUsingCache(withUrl: imgurl, fail: { error in
            self.avatar.loadImageUsingCache(withUrl: String(format: "https://api.adorable.io/avatars/%d/%@", Int(128 * UIScreen.main.scale), pubKey), fail: nil)
        })

    }
    
    func getBalance(pubKey: String, callback: ((String) -> Void)?) {
        let url = String(format: "%@/tx/sources/%@", "default_node".localized(), pubKey)
        
        let request = Request(url: url)
        
        request.jsonDecodeWithCallback(type: SourceResponse.self, callback: { sourceResponse in
            let sources = sourceResponse.sources
            var currency = "Ğ1"
            switch sourceResponse.currency {
            case "g1":
                currency = "Ğ1"
            case "g1du":
                currency = "Ğ1DU"
            default:
                currency = sourceResponse.currency
            }

            let amounts = sources.map {$0.amount}
            let total = amounts.reduce(0, +)
            let str = String(format:"%@ %.2f %@", "balance_label".localized(), Double(total) / 100, currency)
            callback?(str)
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            print ("back")
            self.delegate?.logout()
        }
    }
}
