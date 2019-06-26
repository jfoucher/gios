//
//  TransactionResponse.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct TransactionResponse: Codable {
    var currency: String = "g1"
    var pubkey: String? = nil
    var history: History?
}
