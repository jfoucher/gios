//
//  CloseButton.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import UIKit

class CloseButton: UIView {
    @IBOutlet weak private var closeImageView: UIImageView?
    @IBOutlet weak private var closeLabel: UILabel?
    
    var closeClosure: (() -> Void)?
    
    // init(frame:CGRect) and init?(coder aDecoder: NSCoder)
    // are always required when create custom UIViews
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        guard let view = Bundle.main.loadNibNamed("CloseButton", owner: self, options: nil)?.first as? UIView else {
            return
        }
        
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubviewWithConstraints(view, offset: false)
        
        self.commonInit()
    }
    
    // Here you can add all the view initialization
    func commonInit() {
        self.closeImageView?.with(color: .white)
        self.closeLabel?.text = "close_label".localized()
    }
}

// MARK: IBActions

extension CloseButton {
    @IBAction func closeButton(_ sender: Any) {
        self.closeClosure?()
    }
}
