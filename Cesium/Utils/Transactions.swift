//
//  Transactions.swift
//  Cesium
//
//  Created by Jonathan Foucher on 02/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import CryptoSwift
import Sodium

enum TransactionCreationError: Error {
    case couldNotSignTransaction
    case insufficientFunds
}

class Transactions {
    
    static func createTransaction(response: SourceResponse, receiverPubKey: String, amount: Int, block: Block, comment: String) throws -> String {
        
        var tx = """
Version: 10
Type: Transaction
Currency: \(block.currency)
Blockstamp: \(block.number)-\(block.hash)
Locktime: 0
Issuers:
\(response.pubkey)
Inputs:

"""
        let inputs = response.sources.map {
            return String(format:"%d:%d:%@:%@:%d", $0.amount, $0.base, $0.type, $0.identifier, $0.noffset)
            }.reduce("") { (res: String, str: String) -> String in
                return (String(res + str + "\n"))
        }
        tx += inputs
        tx += "Unlocks:\n"
        
        for i in 0...response.sources.count-1 {
            tx += String(format:"%d:SIG(0)\n", i)
        }
        
        tx += "Outputs:\n"
        guard let outputs = try calculateOutputs(sources: response.sources, amountToSend: amount, pubKey: receiverPubKey, myPubKey: response.pubkey) else {
            throw TransactionCreationError.insufficientFunds
        }
        
        tx += outputs
        tx += "Comment: \(comment)\n"
        
        guard let signature = try? Transactions.signTransaction(transaction: tx) else {
            throw TransactionCreationError.couldNotSignTransaction
        }

        //return tx
        let signedTx = tx + signature + "\n"
        print(signedTx)
        return signedTx
    }
    
    static func calculateOutputs(sources: [Source], amountToSend: Int, pubKey: String, myPubKey: String) throws -> String? {

        // For each source, take an amount. If that amount is enough, send the rest back to me.
        // If it's not, add the next source
        //output is like : mantissa:exponent:SIG(PUBLIC_KEY)
        var rest = Decimal(amountToSend)
        let toSend = Decimal(amountToSend)
        var ret = ""
        
        for source in sources {
            let sourceAmount = Decimal(sign: FloatingPointSign.plus, exponent: source.base, significand: Decimal(source.amount))
            print("source amount")
            print(sourceAmount)
            print("tosend amount")
            print(toSend)
            if (sourceAmount >= rest) {
                // We have everything we need right here, return now
                let toMe = sourceAmount - toSend
                
                ret += String(format: "%d:%d:SIG(%@)\n", Int(truncating: NSDecimalNumber(decimal: toSend)), 0, pubKey)
                
                if (toMe > 0) {
                    ret += String(format: "%d:%d:SIG(%@)\n", Int(truncating: NSDecimalNumber(decimal: toMe)), 0, myPubKey)
                }
                return ret
            } else {
                //Only send to them with this source
                ret += String(format: "%d:%d:SIG(%@)\n", Int(truncating: NSDecimalNumber(decimal: sourceAmount)), 0, pubKey)
                //Keep going with the other sources
                rest -= sourceAmount
            }
        }

        throw TransactionCreationError.insufficientFunds
    }
    
    static func signTransaction(transaction: String) throws -> String {
        let password: Array<UInt8> = Array("*".utf8)
        let salt: Array<UInt8> = Array("*".utf8)
        guard let seed = try? Scrypt(password: password, salt: salt, dkLen: 32, N: 4096, r: 16, p: 1).calculate() else {
            throw TransactionCreationError.couldNotSignTransaction
        }
        let sodium = Sodium()
        let k = sodium.sign.keyPair(seed: seed)
        if let key = k {
            if let signature = sodium.sign.signature(message: Array(transaction.utf8), secretKey: key.secretKey) {
                return signature.toBase64() ?? ""
            }
        }
        throw TransactionCreationError.couldNotSignTransaction
    }
    
}
