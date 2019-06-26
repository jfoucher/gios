//
//  Certification.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct Certification: Codable {
    var from: String
    var to: String
    var sig: String
    var timestamp: Int
    var expiresIn: Int
}
