// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol SettingsService: AnyObject {
    
    func settings(
        for setting: Setting.ItemIdentifier
    ) -> [Setting]
    
    func didSelect(
        item: Setting.ItemIdentifier?,
        action: Setting.ActionIdentifier
    )
    
    func isInitialized(
        item: Setting.ItemIdentifier
    ) -> Bool
    
    func isSelected(
        item: Setting.ItemIdentifier,
        action: Setting.ActionIdentifier
    ) -> Bool
}
