//
//  ProfileResponse.swift
//  Cesium
//
//  Created by Afx on 26/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

struct ProfileResponse: Codable {
    var _source: Profile? = nil
    var _id: String? = nil
    var _type: String? = nil
    var found: Bool? = nil
}
