//
//  TransactionViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 01/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

import UIKit

class TransactionViewController: UIViewController {
    var transaction: ParsedTransaction?
    var currency: String = "g1"
    @IBOutlet weak var senderAvatar: UIImageView!
    @IBOutlet weak var receiverAvatar: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var receiverName: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var comment: UITextView!
    
    var sender: Profile? {
        didSet {
            print("got sender")
            DispatchQueue.main.async {
                if ( self.sender?.title == nil || self.sender?.uid == nil) {
                    print(self.sender)
                }
                
                self.sender?.getAvatar(imageView: self.senderAvatar)
                self.senderName.text = self.sender?.title != nil ?  self.sender?.title :  self.sender?.uid
            }
        }
    }
    var receiver: Profile? {
        didSet {
            print("got receiver")
            DispatchQueue.main.async {
                if ( self.receiver?.title == nil || self.receiver?.uid == nil) {
                    print(self.receiver)
                }
                self.receiver?.getAvatar(imageView: self.receiverAvatar)
                self.receiverName.text = self.receiver?.title != nil ?  self.receiver?.title :  self.receiver?.uid
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.senderAvatar.layer.borderWidth = 1
        self.senderAvatar.layer.masksToBounds = false
        self.senderAvatar.layer.borderColor = UIColor.white.cgColor
        self.senderAvatar.layer.cornerRadius = self.senderAvatar.frame.width/2
        self.senderAvatar.clipsToBounds = true
        
        self.receiverAvatar.layer.borderWidth = 1
        self.receiverAvatar.layer.masksToBounds = false
        self.receiverAvatar.layer.borderColor = UIColor.white.cgColor
        self.receiverAvatar.layer.cornerRadius = self.receiverAvatar.frame.width/2
        self.receiverAvatar.clipsToBounds = true
        
        self.arrow.tintColor = .white
        self.arrow.image = UIImage(named: "arrow-right")?.withRenderingMode(.alwaysTemplate)
        
        if let am = self.transaction?.amount {
            let currency = Currency.formattedCurrency(currency: self.currency)
            var a = Double(truncating: am as NSNumber)
            if (a < 0) {
                a *= -1
            }
            self.amount.text = String(format: "%.2f %@", a / 100, currency)
            
            
        }
        
        
        if let tx = self.transaction {
            let date = Date(timeIntervalSince1970: Double(tx.time))
            let dateFormatter = DateFormatter()
            dateFormatter.locale = NSLocale.current
            dateFormatter.dateFormat = "dd MMMM YYYY"
            let d = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "HH:mm:ss"
            let t = dateFormatter.string(from: date)
            self.date?.text = String(format: "transaction_view_date_format".localized(), d, t)

            self.comment.text = tx.comment
            self.getSender(pubKey: tx.pubKey)
            if (tx.to.count > 0) {
                self.getReceiver(pubKey: tx.to[0])
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.comment.setContentOffset(.zero, animated: false)
    }
    
    func getSender(pubKey: String) {
        print("getting sender for " + pubKey)
        Profile.getRequirements(publicKey: pubKey, callback: { identity in
            // Force getting profile from public key
            var ident = identity
            if (identity == nil) {
                ident = Identity(pubkey: pubKey, uid: "", sig: nil, meta: nil, certifications: nil)
            }
            Profile.getProfile(publicKey: pubKey, identity: ident, callback: { profile in
                if let prof = profile, let am = self.transaction?.amount {
                    //Reverse display if amount is negative
                    if (am < 0) {
                        self.receiver = prof
                    } else {
                        self.sender = prof
                    }
                } else {
                   print("no profile for " + pubKey)
                }
            })
        })
    }
    
    func getReceiver(pubKey: String) {
        print("getting receiver for " + pubKey)
        Profile.getRequirements(publicKey: pubKey, callback: { identity in
            // Force getting profile from public key
            var ident = identity
            if (identity == nil) {
                ident = Identity(pubkey: pubKey, uid: "", sig: nil, meta: nil, certifications: nil)
            }
            Profile.getProfile(publicKey: pubKey, identity: ident, callback: { profile in
                if let prof = profile, let am = self.transaction?.amount {
                    if (am < 0) {
                        self.sender = prof
                    } else {
                        self.receiver = prof
                    }
                } else {
                    print("no profile for " + pubKey)
                }
            })
        })
    }
}
