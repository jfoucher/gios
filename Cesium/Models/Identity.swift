//
//  Identity.swift
//  Cesium
//
//  Created by Jonathan Foucher on 31/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct IdentityResponse: Codable {
    var identities: [Identity]? = []
}

struct Identity: Codable {
    var pubkey: String
    var uid: String
    var sig: String?
    var meta: Meta?
    var updatedAt: Date?
    var certifications: [Certification]?
    init(pubkey:String, uid: String) {
        self.pubkey = pubkey
        self.uid = uid
    }
}

struct Certification: Codable {
    var from: String
    var to: String
    var sig: String
    var timestamp: Int
    var expiresIn: Int
}

struct Meta: Codable {
    var timestamp: String
}
//
//{
//    "identities": [
//    {
//    "pubkey": "9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k",
//    "uid": "jotest",
//    "sig": "5hXi9bE4J4fLfFxLyX5l7/LHGWhaIsIxYLP7soWvcYXdIII/qb7NElbb9W9vmNLopezvjrZD/FTw5XhF0+LBBA==",
//    "meta": {
//    "timestamp": "225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34"
//    },
//    "revocation_sig": null,
//    "revoked": false,
//    "revoked_on": null,
//    "expired": false,
//    "outdistanced": true,
//    "isSentry": false,
//    "wasMember": false,
//    "certifications": [],
//    "pendingCerts": [],
//    "pendingMemberships": [
//    {
//    "membership": "IN",
//    "issuer": "9itUPU7CVJEHh5DszAYQvgdUvTDLUNkY6NngMfo3F18k",
//    "number": 225170,
//    "blockNumber": 225170,
//    "blockHash": "000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34",
//    "userid": "jotest",
//    "certts": "225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34",
//    "block": "225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34",
//    "fpr": "000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34",
//    "idtyHash": "1DF74256B3D7E13F7D44EE27B34B245E6328788D2D1B5EFFD8F7A4D3C2DA96E3",
//    "written": false,
//    "written_number": null,
//    "expires_on": 1564554530,
//    "signature": "h6WazHb2nf/ZbPJbuwzAbQFPta6oQ0Wl9x16GbSCWo8BJIwFfnGX+WqZbawj1FVWy8UxcZTPkG+PFDvsT5v6Cw==",
//    "expired": null,
//    "blockstamp": "225170-000000315169374279C2B2DD68DB1CD15508DD6F16112E6A5AE00493AB68BB34",
//    "sig": "h6WazHb2nf/ZbPJbuwzAbQFPta6oQ0Wl9x16GbSCWo8BJIwFfnGX+WqZbawj1FVWy8UxcZTPkG+PFDvsT5v6Cw==",
//    "type": "IN"
//    }
//    ],
//    "membershipPendingExpiresIn": 31548719,
//    "membershipExpiresIn": 0
//    }
//    ]
//}
