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
    
    @IBOutlet weak var name: UILabel!
    var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let profileName = self.profile?.title {
            name.text = profileName
        }
        
    }
}
