//
//  FirstViewController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import UIKit
import Sodium
import CryptoSwift



class FirstViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleLoginAction(_ sender: Any) {

        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let viewControllerB = storyBoard.instantiateViewController(withIdentifier: "ProfileView") as! ProfileViewController
        self.present(viewControllerB, animated:true, completion:nil)
    }
}

