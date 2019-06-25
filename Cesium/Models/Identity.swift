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
