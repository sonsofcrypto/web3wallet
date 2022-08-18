// Created by web3d4v on 18/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

extension Array where Element == Network {
    
    var sortedByName: [Network] {
        
        sorted {
            
            guard $0.type != $1.type else {
                
                return $0.name < $1.name
            }
            
            switch ($0.type, $0.type) {
                
            case (.l1, .l2):
                return true
            case (.l1, .l1Test):
                return true
            case (.l1, .l2Test):
                return true
            case (.l1Test, .l2):
                return true
            case (.l1Test, .l2Test):
                return true
            case (.l2, .l2Test):
                return true
            default:
                return false
            }
        }
    }
 }
