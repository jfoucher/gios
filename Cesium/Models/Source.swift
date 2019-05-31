//
//  Transaction.swift
//  Cesium
//
//  Created by Jonathan Foucher on 31/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct SourceResponse: Codable {
    var currency: String = "g1"
    var pubkey: String? = nil
    var sources: [Source] = []
}

struct Source: Codable {
    var type: String? = nil
    var noffset: Int = 0
    var identifier: String? = nil
    var amount: Int
    var base: Int
    var conditions: String? = nil
}

//        {
//            "currency": "g1",
//            "pubkey": "EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq",
//            "sources": [
//            {
//            "type": "T",
//            "noffset": 0,
//            "identifier": "A888D00A7085DD1EEBABCD55A9B2F189FBD7E838E3776DB175857758FCE8AFB2",
//            "amount": 500,
//            "base": 0,
//            "conditions": "SIG(EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq)"
//            }
//            ]
//        }
