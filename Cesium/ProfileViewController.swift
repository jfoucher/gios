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


class ProfileViewController: UIViewController {
    weak var delegate: LogoutDelegate?
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var publicKey: UILabel!
    var profile: Profile?
    
    @IBOutlet weak var avatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let profile = self.profile {
            name.text = profile.title != nil ? profile.title : profile.uid
            self.publicKey.text = profile.issuer
            self.getAvatar(pubKey: profile.issuer)
            
            let url = String(format: "%@/tx/sources/%@", "default_node".localized(), profile.issuer)
            
            let request = Request(url: url)
            
            request.jsonDecodeWithCallback(type: TransactionResponse.self, callback: { transactionResponse in
                let sources = transactionResponse.sources
                print(sources)
                var currency = "Ğ1"
                switch transactionResponse.currency {
                case "g1":
                    currency = "Ğ1"
                case "g1du":
                    currency = "Ğ1DU"
                default:
                    currency = transactionResponse.currency
                }
                print(currency)
                let amounts = sources.map {$0.amount}
                let total = amounts.reduce(0, +)
                print(String(format:"%.2f %@", Double(total) / 100, currency))
            })
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
    
    func getAvatar(pubKey: String) {
        let imgurl = String(format: "%@/user/profile/%@/_image/avatar.png", "default_data_host".localized(), pubKey)
        
        avatar.layer.borderWidth = 1
        avatar.layer.masksToBounds = false
        avatar.layer.borderColor = UIColor.black.cgColor
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.clipsToBounds = true
        
        avatar.loadImageUsingCache(withUrl: imgurl)
        
        if avatar.image == nil {
            avatar.loadImageUsingCache(withUrl: String(format: "https://api.adorable.io/avatars/%d/%@", Int(128 * UIScreen.main.scale), pubKey))
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            print ("back")
            self.delegate?.logout()
        }
    }
}
