// Created by web3d4v on 21/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

extension NSDirectionalEdgeInsets {
    
    static var paddingDefault: Self {
        
        .init(
            top: Theme.constant.padding,
            leading: Theme.constant.padding,
            bottom: Theme.constant.padding,
            trailing: Theme.constant.padding
        )
    }
    
    static var paddingHalf: Self {
        
        .init(
            top: Theme.constant.padding.half,
            leading: Theme.constant.padding.half,
            bottom: Theme.constant.padding.half,
            trailing: Theme.constant.padding.half
        )
    }

}
