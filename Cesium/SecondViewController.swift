//
//  SecondViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    var profile: Profile? {
        didSet {
            print(self.profile?.title)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let profile = self.profile {
            print(profile.title)
        }
    }


}

