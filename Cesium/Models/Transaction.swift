//
//  Transaction.swift
//  Cesium
//
//  Created by Jonathan Foucher on 31/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct TransactionResponse: Codable {
    var currency: String = "g1"
    var pubkey: String? = nil
    var history: History?
}

struct History: Codable {
    var sent: [Transaction] = []
    var received: [Transaction] = []
    var sending: [Transaction] = []
    var receiving: [Transaction] = []
}

struct Transaction: Codable {
    var version: Int
    var received: Int? = nil
    var hash: String? = nil
    var block_number: Int? = nil
    var time: Int? = nil
    var comment: String? = nil
    var issuers: [String] = []
    var inputs: [String] = []
    var outputs: [String] = []
    var signatures: [String] = []
}
