//
//  SourceResponse.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct SourceResponse: Codable {
    var currency: String = "g1"
    var pubkey: String
    var sources: [Source] = []
}
