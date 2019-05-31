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
    
    weak var logindelegate: LoginDelegate?
    weak var logoutdelegate: LogoutDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let vc = self.viewControllers.first as! LoginViewController
        vc.delegate = self
    }
    
    func handleLogin(profile: Profile) {
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let profileView = storyBoard.instantiateViewController(withIdentifier: "ProfileView") as! ProfileViewController
            profileView.delegate = self.logoutdelegate
            profileView.profile = profile
            self.pushViewController(profileView, animated:true)
            
        }
        
    }
    
}



extension FirstViewController: LoginDelegate {
    func login(profile: Profile) {
        print("in delegate 1")
        self.handleLogin(profile: profile)
        self.logindelegate?.login(profile: profile)
    }
}


extension FirstViewController: LogoutDelegate {
    func logout() {
        print("logging out")
        self.logoutdelegate?.logout()
    }
}
