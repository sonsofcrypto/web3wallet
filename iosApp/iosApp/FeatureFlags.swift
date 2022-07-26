// Created by web3d4v on 05/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

enum FeatureFlag {
    
    case showAppsTab
    case embedChatInTab
    
    var isEnabled: Bool {
        
        switch self {
        case .showAppsTab:
            return false
        case .embedChatInTab:
            return false
        }
    }
}
