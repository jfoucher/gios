//
//  NewTransactionViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 01/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit


class NewTransactionViewController: UIViewController {
    var receiver: Profile?
    var sender: Profile?

    @IBOutlet weak var senderAvatar: UIImageView!
    @IBOutlet weak var receiverAvatar: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var transferTo: UILabel!
    @IBOutlet weak var senderBalance: UILabel!
    @IBOutlet weak var receiverName: UILabel!
    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var receiverPubKey: UILabel!
    @IBOutlet weak var senderPubKey: UILabel!
    @IBOutlet weak var amount: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set arrow to white
        self.arrow.tintColor = .white
        self.arrow.image = UIImage(named: "arrow-right")?.withRenderingMode(.alwaysTemplate)
        
        if let receiver = self.receiver {
            self.receiverAvatar.layer.borderWidth = 1
            self.receiverAvatar.layer.masksToBounds = false
            self.receiverAvatar.layer.borderColor = UIColor.white.cgColor
            self.receiverAvatar.layer.cornerRadius = self.receiverAvatar.frame.width/2
            self.receiverAvatar.clipsToBounds = true

            receiver.getAvatar(imageView: self.receiverAvatar)

            self.receiverName.text = receiver.title != nil ? receiver.title : receiver.uid
        }
        
        
        if let sender = self.sender {
            self.senderAvatar.layer.borderWidth = 1
            self.senderAvatar.layer.masksToBounds = false
            self.senderAvatar.layer.borderColor = UIColor.white.cgColor
            self.senderAvatar.layer.cornerRadius = self.receiverAvatar.frame.width/2
            self.senderAvatar.clipsToBounds = true
            
            sender.getAvatar(imageView: self.senderAvatar)
            
            self.senderName.text = sender.title != nil ? sender.title : sender.uid
            
            sender.getBalance(callback: { str in
                DispatchQueue.main.async {
                    self.senderBalance.text = str
                }
            })
        }
        
    }
}
