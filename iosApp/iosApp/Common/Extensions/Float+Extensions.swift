// Created by web3d4v on 23/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension Float {
    
    var double: Double {
        
        Double(self)
    }
    
    func thowsandsFormatted(decimals: Int = 2) -> String {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: self)
    }
}
