//
//  Double+Extensions.swift
//  ingine
//
//  Created by James Timberlake on 4/29/20.
//  Copyright © 2020 ingine. All rights reserved.
//

import Foundation

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
