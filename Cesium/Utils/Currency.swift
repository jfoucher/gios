//
//  Currency.swift
//  Cesium
//
//  Created by Jonathan Foucher on 01/06/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation

class Currency {
    static func formattedCurrency(currency: String) -> String {
        switch currency {
        case "g1":
            return "Ğ1"
        case "g1du":
            return "Ğ1DU"
        default:
            return currency
        }
    }
}
