//
//  UIImageView+Extensions.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func with(color: UIColor) {
        self.image = self.image?.withRenderingMode(.alwaysTemplate)
        self.tintColor = color
    }
    
    func loadImageUsingCache(withUrl urlString : String, fail: ((Error?) -> Void)?) {
        let url = URL(string: urlString)
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        // if not, download image from url
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil {
                fail?(error!)
            }
            if (data != nil) {
                if let image = UIImage(data: data!) {
                    DispatchQueue.main.async {
                        imageCache.setObject(image, forKey: urlString as NSString)
                        self.image = image
                    }
                } else {
                    fail?(nil)
                }
            } else {
                fail?(nil)
            }
            
            
        }).resume()
    }
}
