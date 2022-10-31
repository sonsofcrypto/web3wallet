// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol Web3ServiceWalletListener: AnyObject {

    func notificationsChanged()
    func tokensChanged()
}

extension Web3ServiceWalletListener {
    
    func notificationsChanged() {}
    func tokensChanged() {}
}

protocol Web3ServiceLegacy: AnyObject {
    func addWalletListener(_ listener: Web3ServiceWalletListener)
    func removeWalletListener(_ listener: Web3ServiceWalletListener)
    func setNotificationAsDone(notificationId: String)
    var dashboardNotifications: [Web3Notification] { get }
}

struct Web3Notification: Codable, Equatable {
    
    let id: String
    let image: Data // Security, Social, etc
    let title: String
    let body: String
    let deepLink: String
    let canDismiss: Bool
    let order: Int // 1, 2, 3, 4...(left to right)
}
