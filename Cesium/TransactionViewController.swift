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
    @IBOutlet weak var senderAvatar: UIImageView!
    @IBOutlet weak var receiverAvatar: UIImageView!
    
    var sender: Profile? {
        didSet {
            print("sender loaded")
            self.sender?.getAvatar(imageView: self.senderAvatar)
        }
    }
    var receiver: Profile? {
        didSet {
            print("receiver loaded")
            self.receiver?.getAvatar(imageView: self.receiverAvatar)
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
        
        if let tx = self.transaction {
            self.getSender(pubKey: tx.pubKey)
            if (tx.to.count > 0) {
                self.getReceiver(pubKey: tx.to[0])
            }
        }
    }
    
    func getSender(pubKey: String) {
        Profile.getRequirements(publicKey: pubKey, callback: { identity in
            Profile.getProfile(publicKey: pubKey, identity: identity, callback: { profile in
                if let prof = profile {
                    self.sender = prof
                }
            })
        })
    }
    
    func getReceiver(pubKey: String) {
        Profile.getRequirements(publicKey: pubKey, callback: { identity in
            Profile.getProfile(publicKey: pubKey, identity: identity, callback: { profile in
                if let prof = profile {
                    self.receiver = prof
                }
            })
        })
    }
}
