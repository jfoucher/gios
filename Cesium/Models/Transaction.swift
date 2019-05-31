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
    var blockstampTime: Int
    var blockstamp: String
    var locktime: Int = 0
}


struct ParsedTransaction {
    var amount: Int
    var time: Int
    var inputs: [String] = []
    var sources: [String] = []
    var pubKey: String
    var comment: String
    var isUD: Bool = false
    var hash: String
    var locktime: Int = 0
    var block_number: Int
    
    init(tx: Transaction, pubKey: String) {
        var walletIsIssuer = false;
        var otherIssuer = tx.issuers.reduce("") {
            (res: String, issuer: String) -> String in
            walletIsIssuer = (issuer == pubKey) ? true : walletIsIssuer;
            return issuer + ((res != pubKey) ? ", " + res : "");
        }
        if (otherIssuer.count > 0) {
            otherIssuer = String(otherIssuer.dropLast(2));
        }
        
        var otherReceiver: String = ""
        self.amount = 0
        self.time = 0
        self.pubKey = ""
        self.comment = tx.comment!
        self.hash = tx.hash!
        self.locktime = tx.locktime
        self.block_number = tx.block_number!
        
        let total = tx.outputs.reduce(0) {
            (sum: Int, output: String) -> Int in
            let outputArray = output.components(separatedBy: ":")
            
            print(outputArray)
            
            let outputBase = Int(outputArray[1]);
            let outputAmount = NSDecimalNumber(decimal: pow(Decimal(Int(outputArray[0])!), outputBase!));

            let outputCondition = outputArray[2];
            let pattern = "SIG\\(([0-9a-zA-Z]+)\\)"

            let sigMatches = self.matches(for: pattern, in: outputCondition)
            
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return 0 }
            let range = NSRange(location: 0, length: outputCondition.utf16.count)
            let m = regex.matches(in: outputCondition, options: [], range: range)
            
            let res =  m.map { match in
                return (0..<match.numberOfRanges).map {
                    let rangeBounds = match.range(at: $0)
                    guard let range = Range(rangeBounds, in: text) else {
                        return ""
                    }
                    return String(text[range])
                }
            }
            
            if (sigMatches.count > 0) {
                let outputPubkey = sigMatches[1];
                
                if (outputPubkey == pubKey) { // output is for the wallet
                    if (!walletIsIssuer) {
                        return sum + Int(truncating: outputAmount);
                    }
                }
                else { // output is for someone else
                    if (outputPubkey != "" && outputPubkey != otherIssuer) {
                        otherReceiver = outputPubkey;
                    }
                    if (walletIsIssuer) {
                        return sum - Int(truncating: outputAmount);
                    }
                }
            
            } else if (outputCondition.contains("SIG("+pubKey+")")) {
                print("TODOTODO")
//                var lockedOutput = BMA.tx.parseUnlockCondition(outputCondition);
//                if (lockedOutput) {
//
//                    lockedOutput.amount = outputAmount;
//                    lockedOutputs = lockedOutputs || [];
//                    lockedOutputs.push(lockedOutput);
//                    console.debug('[tx] has locked output:', lockedOutput);
//
//                    return sum + outputAmount;
//                }
            }
            return sum
        }
        
        let txPubkey = amount > 0 ? otherIssuer : otherReceiver;
        let time = tx.time != nil ? tx.time : tx.blockstampTime;
        self.time = time!
        self.amount = total
        self.pubKey = txPubkey
        self.comment = tx.comment!
        self.isUD = false
        
        

        // If pending: store sources and inputs for a later use - see method processTransactionsAndSources()
        if (walletIsIssuer && tx.block_number == nil) {
            self.inputs = tx.inputs;
        }
        
//        if (lockedOutputs) {
//            newTx.lockedOutputs = lockedOutputs;
//        }
    }
    
    func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}

