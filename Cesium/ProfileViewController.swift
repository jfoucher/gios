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
    var profile: Profile?
    
    @IBOutlet weak var avatar: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let profile = self.profile {
            name.text = profile.title
            
            let url = URL(string: String(format: "%@/user/profile/%@/_image/avatar.png", "default_data_host".localized(), profile.issuer))!
            let data = try? Data(contentsOf: url)
            
            if let imageData = data {
                let image = UIImage(data: imageData)
                avatar.image = image
                avatar.layer.borderWidth = 1
                avatar.layer.masksToBounds = false
                avatar.layer.borderColor = UIColor.black.cgColor
                avatar.layer.cornerRadius = avatar.frame.width/2
                avatar.clipsToBounds = true
                
            }
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
