//
//  History.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct History: Codable {
    var sent: [Transaction] = []
    var received: [Transaction] = []
    var sending: [Transaction] = []
    var receiving: [Transaction] = []
}
