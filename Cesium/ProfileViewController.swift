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
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var amount: UIButton!
    @IBOutlet weak var avatar: UIImageView!
    var profile: Profile?
    var transaction: ParsedTransaction?
}

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var changeUserDelegate: ViewUserDelegate?

    @IBOutlet weak var check: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var balance: UILabel!
    @IBOutlet weak var publicKey: UILabel!
    @IBOutlet weak var keyImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatar: UIImageView!
    
    var profile: Profile? {
        didSet {
            let nav = self.navigationController as! FirstViewController
            nav.selectedProfile = profile
        }
    }
    var sections: [TransactionSection]? = []
    var currency: String = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.rowHeight = 64.0
        // Do any additional setup after loading the view.
        if let profile = self.profile {
            self.name.text = profile.title != nil ? profile.title : profile.uid
            self.balance.text = "balance_label".localized()
            self.publicKey.text = profile.issuer
            
            self.avatar.layer.borderWidth = 1
            self.avatar.layer.masksToBounds = false
            self.avatar.layer.borderColor = UIColor.white.cgColor
            self.avatar.layer.cornerRadius = avatar.frame.width/2
            self.avatar.clipsToBounds = true
            
            profile.getAvatar(imageView: self.avatar)
            
            self.keyImage.tintColor = .white
            self.keyImage.image = UIImage(named: "key")?.withRenderingMode(.alwaysTemplate)
            
            let backItem = UIBarButtonItem()
            backItem.title = profile.title != nil ? profile.title : profile.uid
            backItem.tintColor = .white
            self.navigationItem.backBarButtonItem = backItem
            
            self.check.tintColor = .white
            self.check.image = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
            
            self.check.isHidden = true
            if let ident = profile.identity {
                if (ident.certifications.count >= 5) {
                    self.check.isHidden = false
                }
            }
            
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
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! TransactionTableViewCell
        //DispatchQueue.main.async {
            //let transactionView = self.storyboard!.instantiateViewController(withIdentifier: "MyTransactionView")
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let transactionView = storyBoard.instantiateViewController(withIdentifier: "MyTransactionView") as! TransactionViewController
            
            if let tx = cell.transaction {
                transactionView.transaction = tx
                self.navigationController?.pushViewController(transactionView, animated: true)
            }
        //}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrototypeCell", for: indexPath) as! TransactionTableViewCell

        // [0, 0]
        if let sections = self.sections {
            let sects = sections.filter { (section) -> Bool in
                section.transactions.count > 0
            }
            
            let transaction = sects[indexPath[0]].transactions[indexPath[1]]
            cell.transaction = transaction
            let pk = transaction.pubKey
            cell.name?.text = ""
            
            let date = Date(timeIntervalSince1970: Double(transaction.time))
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd/MM/YYYY HH:mm:ss"
            cell.date?.text = dateFormatter.string(from: date)
            
            let am = Double(truncating: transaction.amount as NSNumber)
            let currency = self.formattedCurrency(currency: self.currency)
            cell.amount?.setTitle(String(format: "%.2f \(currency)", am / 100), for: .normal)
            if (am <= 0) {
                cell.amount?.backgroundColor = .none
                cell.amount?.tintColor = .lightGray
            } else {
                cell.amount?.backgroundColor = .init(red: 0, green: 132/255.0, blue: 100/255.0, alpha: 1)
                cell.amount?.tintColor = .white
                if let frame = cell.amount?.frame {
                    cell.amount?.layer.cornerRadius = frame.height / 2
                }
                
                //cell.amount?.titleEdgeInsets = UIEdgeInsets(top: 3, left: 6, bottom: 3, right: 6)
            }
            
            // This is two requests per cell, maybe we should get all the users and work with that instead
            Profile.getRequirements(publicKey: pk, callback: { identity in
                if (identity == nil) {
                    print(pk)
                }

                Profile.getProfile(publicKey: pk, identity: identity, callback: { profile in
                    if let prof = profile {
                        cell.profile = prof
                        prof.getAvatar(imageView: cell.avatar)
                        DispatchQueue.main.async {
                            cell.name?.text = prof.title != nil ? prof.title : prof.uid
                        }
                    }
                })
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = self.tableView.cellForRow(at: indexPath) as! TransactionTableViewCell

        if let profile = cell.profile {
            self.changeUserDelegate?.viewUser(profile: profile)
        }
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

        let transactionRequest = Request(url: url)
        
        transactionRequest.jsonDecodeWithCallback(type: TransactionResponse.self, callback: { transactionResponse in
            self.currency = transactionResponse.currency
            
            if let history = transactionResponse.history {
                self.sections = self.parseHistory(history: history, pubKey: pubKey)
                
                DispatchQueue.main.async { self.tableView?.reloadData() }
            }
            
            
        }, fail: nil)
    }
    
    func parseHistory(history: History, pubKey: String) -> [TransactionSection] {
        var sent = history.sent.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }.filter { return $0.amount <= 0 }
        var received = history.received.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }.filter { return $0.amount > 0 }
        var sending = history.sending.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }.filter { return $0.amount <= 0 }
        var receiving = history.receiving.map{ return ParsedTransaction(tx: $0, pubKey: pubKey) }.filter { return $0.amount > 0 }
        
        sent.sort { (tr1, tr2) -> Bool in
            return tr1.time > tr2.time
        }
        received.sort { (tr1, tr2) -> Bool in
            return tr1.time > tr2.time
        }
        sending.sort { (tr1, tr2) -> Bool in
            return tr1.time > tr2.time
        }
        receiving.sort { (tr1, tr2) -> Bool in
            return tr1.time > tr2.time
        }
        return [
            TransactionSection.init(type: "sent", transactions: sent),
            TransactionSection.init(type: "received", transactions: received),
            TransactionSection.init(type: "sending", transactions: sending),
            TransactionSection.init(type: "receiving", transactions: receiving)
        ]
    }
    
    func getBalance(pubKey: String, callback: ((String) -> Void)?) {
        let url = String(format: "%@/tx/sources/%@", "default_node".localized(), pubKey)
        
        let request = Request(url: url)
        
        request.jsonDecodeWithCallback(type: SourceResponse.self, callback: { sourceResponse in
            let sources = sourceResponse.sources
            let currency = self.formattedCurrency(currency: sourceResponse.currency)
            
            let amounts = sources.map {$0.amount}
            let total = amounts.reduce(0, +)
            let str = String(format:"%@ %.2f %@", "balance_label".localized(), Double(total) / 100, currency)
            callback?(str)
        }, fail: nil)
    }
    
    func formattedCurrency(currency: String) -> String {
        switch currency {
        case "g1":
            return "Ğ1"
        case "g1du":
            return "Ğ1DU"
        default:
            return currency
        }
    }
    

}
