// Created by web3d3v on 18/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class DefaultSettingsService {

    let defaults: UserDefaults
    let keyStoreService: KeyStoreService

    init(
        defaults: UserDefaults,
        keyStoreService: KeyStoreService
    ) {
        
        self.defaults = defaults
        self.keyStoreService = keyStoreService
    }
    
    func isInitialized(
        item: Setting.ItemIdentifier
    ) -> Bool {
        
        defaults.string(forKey: item.rawValue) != nil
    }
    
    func didSelect(
        item: Setting.ItemIdentifier?,
        action: Setting.ActionIdentifier,
        fireAction: Bool
    ) {
        
        if let item = item {
            
            defaults.set(action.rawValue, forKey: item.rawValue)
            defaults.synchronize()
        }
        
        if fireAction {
            
            fire(action: action)
        }
    }
}

extension DefaultSettingsService: SettingsService {
    
    func settings(
        for setting: Setting.ItemIdentifier
    ) -> [Setting] {
        
        switch setting {
            
        case .theme:
            
            return [
                .init(
                    title: Localized("settings.theme.miami"),
                    type: .action(
                        item: .theme,
                        action: .themeMiami,
                        showTickOnSelected: true
                    )
                ),
                .init(
                    title: Localized("settings.theme.ios"),
                    type: .action(
                        item: .theme,
                        action: .themeIOS,
                        showTickOnSelected: true
                    )
                )
            ]
            
        case .debug:
            
            return [
                .init(
                    title: Localized("settings.debug.apis"),
                    type: .item(.debugAPIs)
                )
            ]

        case .debugAPIs:
            
            return [
                .init(
                    title: Localized("settings.debug.apis.nfts"),
                    type: .item(.debugAPIsNFTs)
                )
            ]
            
        case .debugAPIsNFTs:
            
            return [
                .init(
                    title: Localized("settings.debug.apis.nfts.openSea"),
                    type: .action(
                        item: .debugAPIsNFTs,
                        action: .debugAPIsNFTsOpenSea,
                        showTickOnSelected: true
                    )
                ),
                .init(
                    title: Localized("settings.debug.apis.nfts.mock"),
                    type: .action(
                        item: .debugAPIsNFTs,
                        action: .debugAPIsNFTsMock,
                        showTickOnSelected: true
                    )
                )
            ]
        }
    }
    
    func didSelect(
        item: Setting.ItemIdentifier?,
        action: Setting.ActionIdentifier
    ) {
        
        didSelect(item: item, action: action, fireAction: true)
    }
    
    func isSelected(
        item: Setting.ItemIdentifier,
        action: Setting.ActionIdentifier
    ) -> Bool {
        
        defaults.string(forKey: item.rawValue) == action.rawValue
    }
}

private extension DefaultSettingsService {
    
    func fire(
        action: Setting.ActionIdentifier
    ) {
        
        switch action {
            
        case .debugAPIsNFTsOpenSea, .debugAPIsNFTsMock:
            ServiceDirectory.rebootApp()
            
        case .themeIOS, .themeMiami:
            Theme = appTheme
            
        case .resetKeystore:
            keyStoreService.items().forEach {
                keyStoreService.remove(item: $0)
            }
            ServiceDirectory.rebootApp()
        }
    }
}
