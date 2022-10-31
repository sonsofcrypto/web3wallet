// Created by web3d3v on 29/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class IntegrationWeb3Service {
    private let networksService: NetworksService
    private let defaults: UserDefaults
    private var listeners: [Web3ServiceWalletListener] = []

    init(
        networksService: NetworksService,
        defaults: UserDefaults = .standard
    ) {
        self.networksService = networksService
        self.defaults = defaults
    }
}

extension IntegrationWeb3Service: Web3ServiceLegacy {
    
    func addWalletListener(_ listener: Web3ServiceWalletListener) {
        guard !listeners.contains(where: { $0 === listener}) else { return }
        listeners.append(listener)
    }
    
    func removeWalletListener(_ listener: Web3ServiceWalletListener) {
        listeners.removeAll { $0 === listener }
    }

    func setNotificationAsDone(notificationId: String) {
        if notificationId == "modal.mnemonic.confirmation" {
            let walletId = networksService.wallet()?.id() ?? ""
            defaults.set(true, forKey: "\(notificationId).\(walletId)")
            defaults.synchronize()
            listeners.forEach { $0.notificationsChanged() }
        }
    }
    
    var dashboardNotifications: [Web3Notification] {
        var notifications = [Web3Notification]()
        if let walletId = networksService.wallet()?.id(),
            !defaults.bool(forKey: "modal.mnemonic.confirmation.\(walletId)")
        {
            notifications.append(
                .init(
                    id: "1",
                    image: makeSecurityImageData(letter: "s"),
                    title: "Mnemonic",
                    body: "Confirm your mnemonic",
                    deepLink: "modal.mnemonic.confirmation",
                    canDismiss: false,
                    order: 1
                )
            )
        }
        notifications.append(
            .init(
                id: "2",
                image: makeSecurityImageData(letter: "t"),
                title: "App Themes",
                body: "Fancy a new look?",
                deepLink: "settings.themes",
                canDismiss: false,
                order: 2
            )
        )
        notifications.append(
            .init(
                id: "3",
                image: makeSecurityImageData(letter: "f"),
                title: "App Features",
                body: "Your opinion matters to us",
                deepLink: "modal.features",
                canDismiss: false,
                order: 2
            )
        )
        return notifications
    }
}

private extension IntegrationWeb3Service {
    
    func makeSecurityImageData(
        letter: String
    ) -> Data {
        
        let config = UIImage.SymbolConfiguration(
            paletteColors: [
                Theme.colour.labelPrimary,
                .clear
            ]
        )
        
        return "\(letter).circle.fill".assetImage!
            .applyingSymbolConfiguration(config)!
            .pngData()!
    }
}
