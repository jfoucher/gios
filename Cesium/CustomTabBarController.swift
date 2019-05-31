//
//  TabBarController.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit

class CustomTabBarController:  UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad(){
        super.viewDidLoad()

        self.viewControllers?.forEach({ (cont) in
            if (NSStringFromClass(type(of: cont)) == "Cesium.FirstViewController") {
                let first = cont as! FirstViewController
                first.logindelegate = self
                first.logoutdelegate = self
            }
        })
        let tabBarControllerItems = self.tabBar.items
        if let tabArray = tabBarControllerItems {
            
            let tabBarItem1 = tabArray[1]
            let tabBarItem2 = tabArray[2]
            
            tabBarItem1.isEnabled = false
            tabBarItem2.isEnabled = false
        }
        
        
    }
    

}


protocol LoginDelegate: class {
    func login(profile: Profile)
}


protocol LogoutDelegate: class {
    func logout()
}

extension CustomTabBarController: LoginDelegate {
    func login(profile: Profile) {
        DispatchQueue.main.async {
            let tabBarControllerItems = self.tabBar.items
            if let tabArray = tabBarControllerItems {
                
                let tabBarItem1 = tabArray[1]
                let tabBarItem2 = tabArray[2]
                tabArray[0].title = "account_tab_label".localized()
                tabBarItem1.isEnabled = true
                tabBarItem2.isEnabled = true
            }
        }
    }
}

extension CustomTabBarController: LogoutDelegate {
    func logout() {
        DispatchQueue.main.async {
            let tabBarControllerItems = self.tabBar.items
            if let tabArray = tabBarControllerItems {
                
                let tabBarItem1 = tabArray[1]
                let tabBarItem2 = tabArray[2]
                tabArray[0].title = "login_tab_label".localized()
                tabBarItem1.isEnabled = false
                tabBarItem2.isEnabled = false
            }
        }
    }
}
