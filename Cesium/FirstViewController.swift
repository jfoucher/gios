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
        vc.loginDelegate = self
        vc.loginFailedDelegate = self
        if let profile = Profile.load() {
            self.login(profile: profile)
        }
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

protocol LoginFailedDelegate: class {
    func loginFailed(error: String)
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


extension FirstViewController: LoginFailedDelegate {
    func loginFailed(error: String) {
        print("This account does not exist, do you want to create it or try again?")
        //TODO display modal with signup
        DispatchQueue.main.async {
            let alertController = UIAlertController( title: "account_does_not_exist_title".localized(),
                                                     message: "account_does_not_exist_message".localized(),
                                                     preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: "account_does_not_exist_cancel".localized(), style: .cancel, handler: {
                action in
                print("Cancel pressed")
            })
            let saveAction = UIAlertAction(title: "account_does_not_exist_create".localized(), style: .default, handler: {
                action in
                // TODO create account here
                // Display license
                // https://g1.duniter.fr/license/license_g1-fr-FR.html
                // Ask for username, check https://g1.nordstrom.duniter.org/wot/lookup/JOTEST
                // to see if available
                // Ask for salt and password
                // make request to
                // https://g1.nordstrom.duniter.org/tx/sources/9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k
                // Ask for credentials AGAIN???
                // Make POST request to https://g1.nordstrom.duniter.org/wot/add
                // with params
                // {"identity":"Version: 10\nType: Identity\nCurrency: g1\nIssuer: 9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k\nUniqueID: jotest\nTimestamp: 225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34\n5hXi9bE4J4fLfFxLyX5l7/LHGWhaIsIxYLP7soWvcYXdIII/qb7NElbb9W9vmNLopezvjrZD/FTw5XhF0+LBBA==\n"}
                // RESPONSE
//                {
//                    "pubkey": "9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k",
//                    "uids": [],
//                    "signed": []
//                }
                // Make post request to https://g1.nordstrom.duniter.org/blockchain/membership
                // with params
                // {"membership":"Version: 10\nType: Membership\nCurrency: g1\nIssuer: 9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k\nBlock: 225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34\nMembership: IN\nUserID: jotest\nCertTS: 225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34\nh6WazHb2nf/ZbPJbuwzAbQFPta6oQ0Wl9x16GbSCWo8BJIwFfnGX+WqZbawj1FVWy8UxcZTPkG+PFDvsT5v6Cw==\n"}
                //RESPONSE
                //                {
                //                    "signature": "h6WazHb2nf/ZbPJbuwzAbQFPta6oQ0Wl9x16GbSCWo8BJIwFfnGX+WqZbawj1FVWy8UxcZTPkG+PFDvsT5v6Cw==",
                //                    "membership": {
                //                        "version": "10",
                //                        "currency": "g1",
                //                        "issuer": "9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k",
                //                        "membership": "IN",
                //                        "date": 0,
                //                        "sigDate": 0,
                //                        "raw": "Version: 10\nType: Membership\nCurrency: g1\nIssuer: 9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k\nBlock: 225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34\nMembership: IN\nUserID: jotest\nCertTS: 225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34\n"
                //                    }
                //                }

                print("Save pressed.")
            })
            alertController.addAction(cancelAction)
            //alertController.addAction(saveAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
