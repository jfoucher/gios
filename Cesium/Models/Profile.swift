//
//  Profile.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct ProfileResponse: Codable {
    var _source: Profile? = nil
    var _id: String? = nil
    var found: Bool? = nil
}

struct Profile: Codable {
    var uid: String? = nil
    var address: String? = nil
    var city: String? = nil
    var title: String? = nil
    var issuer: String
    var signature: String? = nil
    var hash: String? = nil
    var socials: [Social]? = []
    
    init(issuer: String) {
        self.issuer = issuer
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self) {
            UserDefaults.standard.set(encoded, forKey: "profile")
        }
    }
    
    static func remove() {
        UserDefaults.standard.removeObject(forKey: "profile")
    }
    
    static func load() -> Profile? {
        if let savedProfile = UserDefaults.standard.object(forKey: "profile") as? Data {
            let decoder = JSONDecoder()
            if let loadedProfile = try? decoder.decode(Profile.self, from: savedProfile) {
                return loadedProfile
            }
        }
        return nil
    }
}
struct Social: Codable {
    var url: String
    var type: String? = nil
}

