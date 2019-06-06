//
//  Duniter.swift
//  Cesium
//
//  Created by Jonathan Foucher on 06/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
struct DuniterResponse: Codable {
    var duniter: Duniter
}
struct Duniter: Codable {
    var software: String
    var version: String
    var forkWindowSize: Int
}
