//
//  Transactions.swift
//  Cesium
//
//  Created by Jonathan Foucher on 02/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

class Transactions {
    
    static func createTransaction(response: SourceResponse) {
        
        var tx = """
Version: 10
Type: Transaction
Currency: g1
Blockstamp: block.number-block.hash
Locktime: 0
Issuers: pubKey
Inputs:

"""
        let inputs = response.sources.map {
            return String(format:"%@:%@:%@:%@:@", $0.amount, $0.base, $0.type, $0.identifier, $0.noffset)
            }.reduce("") { (res: String, str: String) -> String in
                return (String(res + str + "\n"))
        }
        tx += "Unlocks: \n"
        
        for i in 0...response.sources.count-1 {
            tx += String(format:"%d:SIG(0)\n", i)
        }
        
        tx += "Outputs:\n"
    }
}
