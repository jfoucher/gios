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
    var address: String? = nil
    var city: String? = nil
    var title: String? = nil
    var issuer: String
    var signature: String
    var hash: String
    var socials: [Social]? = []
}
struct Social: Codable {
    var url: String
    var type: String? = nil
}


//{
//    "_id" = EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq;
//    "_index" = user;
//    "_source" =     {
//        address = "N\U00b0 5 Lestap";
//        avatar =         {
//            "_content_type" = "image/png";
//        };
//        city = Albine;
//        hash = B5B2FBABF490072400D728603EAC9961AE9244BAB0F5ACD8291A0B92F28E6789;
//        issuer = EEdwxSkAuWyHuYMt4eX5V81srJWVy7kUaEkft3CWLEiq;
//        signature = "suABbw+NJrYox3PRobgnFiZvwo/2PsvGjFVyaffrL+f3Um5pFtALeCrzqhmeewCE4UF6NKXEgv1vvnizLbpTDQ==";
//        socials =         (
//            {
//                url = "jfoucher.com";
//        },
//            {
//                type = facebook;
//                url = "https://facebook.com/jfoucher";
//        },
//            {
//                type = twitter;
//                url = "https://twitter.com/jfoucher";
//        }
//        );
//        time = 1498421895;
//        title = "Foucher, Jonathan";
//    };
//    "_type" = profile;
//    "_version" = 1;
//    found = 1;
//}
