// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol SettingsInteractor: AnyObject {
    func settings(
        for setting: Setting.ItemIdentifier
    ) -> [SettingsWireframeContext.Group]
    func didSelect(
        item: Setting.ItemIdentifier?,
        action: Setting.ActionIdentifier
    )
    func isSelected(
        item: Setting.ItemIdentifier,
        action: Setting.ActionIdentifier
    ) -> Bool
}

final class DefaultSettingsInteractor {
    private let settingsService: SettingsService

    init(_ settingsService: SettingsService) {
        self.settingsService = settingsService
    }
}

extension DefaultSettingsInteractor: SettingsInteractor {

    func settings(
        for setting: Setting.ItemIdentifier
    ) -> [SettingsWireframeContext.Group] {
        settingsService.settings(for: setting)
    }
    
    func didSelect(
        item: Setting.ItemIdentifier?,
        action: Setting.ActionIdentifier
    ) {
        settingsService.didSelect(item: item, action: action)
    }
    
    func isSelected(
        item: Setting.ItemIdentifier,
        action: Setting.ActionIdentifier
    ) -> Bool {
        settingsService.isSelected(item: item, action: action)
    }
}
