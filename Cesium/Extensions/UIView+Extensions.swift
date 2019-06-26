//
//  UIView+Extension.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    public func addSubviewWithConstraints(_ subview:UIView, offset:Bool = true) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        let views = [
            "subview" : subview
        ]
        addSubview(subview)
        
        var constraints = NSLayoutConstraint.constraints(withVisualFormat: offset ? "H:|-[subview]-|" : "H:|[subview]|", options: [.alignAllLeading, .alignAllTrailing], metrics: nil, views: views)
        constraints.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: offset ? "V:|-[subview]-|" : "V:|[subview]|", options: [.alignAllTop, .alignAllBottom], metrics: nil, views: views))
        NSLayoutConstraint.activate(constraints)
    }
}
