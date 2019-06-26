//
//  Hits.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct Hits: Codable {
    var total: Int? = 0
    var hits: [ProfileResponse]
}
