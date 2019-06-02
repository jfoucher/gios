//
//  Block.swift
//  Cesium
//
//  Created by Jonathan Foucher on 02/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct Block: Codable {
    var version: Int
    var currency: String
    var time: Int
    var hash: String
    var number: Int
}
