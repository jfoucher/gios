//
//  Transaction.swift
//  Cesium
//
//  Created by Jonathan Foucher on 31/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct Transaction: Codable, Comparable {
    // https://git.duniter.org/nodes/typescript/duniter/issues/1382
    //var version: Int?
    var received: Int? = nil
    var hash: String? = nil
    var currency: String? = nil
    var block_number: Int? = nil
    var time: Int?
    var comment: String? = nil
    var issuers: [String] = []
    var inputs: [String] = []
    var outputs: [String] = []
    var signatures: [String] = []
    var blockstampTime: Int?
    var blockstamp: String?
    
    var locktime: Int = 0
    
    static func < (lhs: Transaction, rhs: Transaction) -> Bool {
        return lhs.time! < rhs.time!
    }
}
