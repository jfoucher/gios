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
    @IBOutlet weak var createTransaction: UIButton!
    
    
    var profile: Profile? {
        didSet {
            if let nav = self.navigationController as? FirstViewController {
                nav.selectedProfile = profile
            }
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
            // make key image white
            self.keyImage.tintColor = .white
            self.keyImage.image = UIImage(named: "key")?.withRenderingMode(.alwaysTemplate)
            
            // Make checkmark image white
            self.check.tintColor = .white
            self.check.image = UIImage(named: "check")?.withRenderingMode(.alwaysTemplate)
            
            // Add image to send button
            let imv = UIImage(named: "g1")?.withRenderingMode(.alwaysTemplate)
            
            self.createTransaction.setImage(imv?.resize(width: 18), for: .normal)
            self.createTransaction.setTitle("transfer_button_label".localized(), for: .normal)
            self.createTransaction.layer.cornerRadius = 6
            
            let ctrl = self.navigationController as! FirstViewController
            if (self.profile?.issuer == ctrl.profile?.issuer) {
                //self.createTransaction.removeFromSuperview()
            }
            // Make back button white
            let backItem = UIBarButtonItem()
            backItem.title = profile.title != nil ? profile.title : profile.uid
            backItem.tintColor = .white
            self.navigationItem.backBarButtonItem = backItem
            
            
            
            self.check.isHidden = true
            if let ident = profile.identity {
                if let certs = ident.certifications {
                    if (certs.count >= 5) {
                        self.check.isHidden = false
                    }
                }
            }
            
            profile.getBalance(callback: { total in
                let str = String(format:"%@ %.2f %@", "balance_label".localized(), Double(total) / 100, Currency.formattedCurrency(currency: self.currency))
                self.profile?.balance = total
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
    
    @IBAction func createTransaction(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let newTransactionView = storyBoard.instantiateViewController(withIdentifier: "NewTransactionView") as! NewTransactionViewController

        newTransactionView.receiver = self.profile
        let ctrl = self.navigationController as! FirstViewController
        newTransactionView.sender = ctrl.profile
        newTransactionView.currency = self.currency
        newTransactionView.isModalInPopover = true
        
        self.navigationController?.present(newTransactionView, animated: true, completion: nil)
        //self.navigationController?.pushViewController(transactionView, animated: true)
        
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
                transactionView.currency = self.currency
                transactionView.isModalInPopover = true
                
                self.navigationController?.present(transactionView, animated: true, completion: nil)
                //self.navigationController?.pushViewController(transactionView, animated: true)
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
            let currency = Currency.formattedCurrency(currency: self.currency)
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
                var ident = identity
                if (identity == nil) {
                    ident = Identity(pubkey: pk, uid: "", sig: nil, meta: nil, certifications: nil)
                }

                Profile.getProfile(publicKey: pk, identity: ident, callback: { profile in
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
        let url = String(format: "%@/tx/history/%@", currentNode, pubKey)

        let transactionRequest = Request(url: url)
        
        transactionRequest.jsonDecodeWithCallback(type: TransactionResponse.self, callback: { err, transactionResponse in
            if let currency = transactionResponse?.currency, let history = transactionResponse?.history {
                self.currency = currency
                self.sections = self.parseHistory(history: history, pubKey: pubKey)
                
                DispatchQueue.main.async { self.tableView?.reloadData() }
            } else if (err != nil) {
                self.errorAlert(title: "no_internet_title".localized(), message: "no_internet_message".localized())
            }
        })
    }
    
    func errorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
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
}

