//
//  UIImage+Extensions.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import UIKit

extension UIImage {
    func resize(width: CGFloat) -> UIImage {
        let scale = width / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: newHeight), false, UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: width, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}
