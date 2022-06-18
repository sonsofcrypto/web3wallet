// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

extension Double {
    
    func toString(decimals: Int = 2) -> String {
        
        String(format: "%.\(decimals)f", self)
    }
    
    
}
