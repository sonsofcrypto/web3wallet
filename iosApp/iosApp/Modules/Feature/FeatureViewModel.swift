// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

struct FeatureViewModel {

    let title: String
    let details: [Details]
    let selectedIndex: Int

    struct Details {
        
        let name: String
        let status: Status
        let summary: Summary
        
        struct Status {
            
            let title: String
            let color: UIColor // HEX
        }
        
        struct Summary {
            
            let title: String
            let summary: String
        }
    }
}
