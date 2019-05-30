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
    var homeViewController: FirstViewController!
    var secondViewController: SecondViewController!
    var thirdViewController: ThirdViewController!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        homeViewController = FirstViewController()
        secondViewController = SecondViewController()
        thirdViewController = ThirdViewController()
        
        let tabBarControllerItems = self.tabBar.items
        print("tabbar did load")
        if let tabArray = tabBarControllerItems {
            print("tabararray")
            let tabBarItem1 = tabArray[1]
            let tabBarItem2 = tabArray[2]
            
            tabBarItem1.isEnabled = false
            tabBarItem2.isEnabled = false
        }
    }
}
