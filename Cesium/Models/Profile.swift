//
//  Profile.swift
//  Cesium
//
//  Created by Jonathan Foucher on 30/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import UIKit


struct ProfileSearchResponse: Codable {
    var hits: Hits

}

struct Hits: Codable {
    var total: Int? = 0
    var hits: [ProfileResponse]
}
 

struct ProfileResponse: Codable {
    var _source: Profile? = nil
    var _id: String? = nil
    var _type: String? = nil
    var found: Bool? = nil
}

struct Profile: Codable {
    var uid: String? = nil
    var address: String? = nil
    var city: String? = nil
    var title: String? = nil
    var time: Int? = nil
    var kp: String? = nil
    var issuer: String
    var signature: String? = nil
    var hash: String? = nil
    var balance: Int?
    var socials: [Social]? = []
    var identity: Identity?
    var sourceResponse: SourceResponse?
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
    
    func getBalance(callback: ((Int) -> Void)?) {
        let pubKey = self.issuer
        let url = String(format: "%@/tx/sources/%@", "default_node".localized(), pubKey)
        
        let request = Request(url: url)
        
        request.jsonDecodeWithCallback(type: SourceResponse.self, callback: { err, sourceResponse in
            
            if let sources = sourceResponse?.sources, let currency = sourceResponse?.currency {
                let amounts = sources.map {$0.amount}
                let total = amounts.reduce(0, +)
 
                callback?(total)
            }
            
        })
    }
    
    func getSources(callback: ((Error?, SourceResponse?) -> Void)?) {
        let pubKey = self.issuer
        let url = String(format: "%@/tx/sources/%@", "default_node".localized(), pubKey)
        
        let request = Request(url: url)
        
        request.jsonDecodeWithCallback(type: SourceResponse.self, callback: { err, sourceResponse in
            callback?(err, sourceResponse)
        })
    }
    
    func getAvatar(imageView: UIImageView) {
        let imgurl = String(format: "%@/user/profile/%@/_image/avatar.png", "default_data_host".localized(), self.issuer)
        let defaultAvatarUrl = String(format: "https://api.adorable.io/avatars/%d/%@", Int(128 * UIScreen.main.scale), self.issuer)
        
        imageView.loadImageUsingCache(withUrl: imgurl, fail: { error in
            imageView.loadImageUsingCache(withUrl: defaultAvatarUrl, fail: nil)
        })
    }
    
    
    static func getRequirements(publicKey: String, callback: ((Identity?) -> Void)?) {
        let url = String(format: "%@/wot/requirements/%@", "default_node".localized(), publicKey)
        
        let request = Request(url: url)
        
        request.jsonDecodeWithCallback(type: IdentityResponse.self, callback: { err, identityResponse in
            if let identities = identityResponse?.identities {
                // TODO think about how to handle multiple identities
                if let ident = identities.first {
                    callback?(ident)
                }
            } else {
                // display error message
                callback?(nil)
            }
        })
    }
    

    
    static func getProfile(publicKey: String, identity: Identity?, callback: ((Profile?) -> Void)?) {
        let url = String(format: "%@/user/profile/%@?_source_exclude=avatar._content", "default_data_host".localized(), publicKey)
        
        let request = Request(url: url)
        var profile = Profile(issuer: publicKey)
        if let ident = identity {
            profile.uid = ident.uid
            profile.signature = ident.sig
            profile.identity = ident
        } else {
            callback?(nil)
            return
        }
        
        
        request.jsonDecodeWithCallback(type: ProfileResponse.self, callback: { err, profileResponse in
            if let fullProfile = profileResponse?._source {
                //We have the profile data, save and display
                profile = fullProfile
                if let id = identity {
                    profile.uid = id.uid
                    profile.signature = id.sig
                    profile.identity = id
                }
            }
            
            callback?(profile)
        })
    }
}
struct Social: Codable {
    var url: String
    var type: String? = nil
}

