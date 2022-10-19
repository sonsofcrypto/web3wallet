// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

struct DashboardViewModel {
    let shouldAnimateCardSwitcher: Bool
    let sections: [DashboardViewModel.Section]
}

extension DashboardViewModel {

    struct Section {
        let header: Header
        let items: Items
        
        enum Header {
            case balance([Formatters.Output])
            case network(Network)
            case title(String)
            case none

            struct Network {
                let id: String
                let name: String
                let fuelCost: String
                let rightActionTitle: String
                let isCollapsed: Bool
            }
        }
        
        enum Items {
            case actions([DashboardViewModel.Action])
            case notifications([DashboardViewModel.Notification])
            case wallets([DashboardViewModel.Wallet])
            case nfts([DashboardViewModel.NFT])
        }
    }

    func header(at idx: Int) -> DashboardViewModel.Section.Header? {
        sections[safe: idx]?.header
    }
}

extension DashboardViewModel.Section.Items {

    func isSameKind(_ other: DashboardViewModel.Section.Items?) -> Bool {
        guard let other = other else { return false }
        switch (self, other) {
        case (.actions, .actions): return true
        case (.notifications, .notifications): return true
        case (.wallets, .wallets): return true
        case (.nfts, .nfts): return true
        default: return false
        }
    }
}

extension DashboardViewModel {

    struct Action {
        let title: String
        let imageName: String
        let type: `Type`

        enum `Type` {
            case send
            case receive
            case swap
        }
    }
}

extension DashboardViewModel {

    struct Notification {
        let id: String
        let image: Data
        let title: String
        let body: String
        let canDismiss: Bool
    }
}

extension DashboardViewModel {

    struct Wallet {
        let name: String
        let ticker: String
        let colors: [String]
        let imageName: String
        let fiatPrice: FiatFormatterViewModel
        let fiatBalance: FiatFormatterViewModel
        let cryptoBalance: CurrencyFormatterViewModel
        let pctChange: String
        let priceUp: Bool
        let candles: CandlesViewModel
    }
}

extension DashboardViewModel {
    struct NFT {
        let image: String
        let onSelected: () -> Void
    }
}

extension DashboardViewModel.Section {
    var hasSectionHeader: Bool {
        switch header {
        case .none: return false
        case .title, .balance, .network: return true
        }
    }

    var isCollapsed: Bool {
        switch header {
        case let .network(network): return network.isCollapsed
        default: return false }
    }
    
    var networkId: String {
        switch header {
        case let .network(network): return network.id
        default: return "" }
    }
}

extension DashboardViewModel.Section.Items {
    var count: Int {
        switch self {
        case .actions: return 1
        case let .notifications(notifications): return notifications.count
        case let .wallets(wallets): return wallets.count
        case let .nfts(nfts): return nfts.count
        }
    }

    var actions: [DashboardViewModel.Action] {
        guard case let .actions(actions) = self else { return [] }
        return actions
    }
    
    func notifications(at index: Int) -> DashboardViewModel.Notification? {
        guard case let .notifications(notifications) = self else { return nil }
        return notifications[safe: index]
    }
    
    func wallet(at index: Int) -> DashboardViewModel.Wallet? {
        guard case let .wallets(wallets) = self else { return nil }
        return wallets[safe: index]
    }

    func nft(at index: Int) -> DashboardViewModel.NFT? {
        guard case let .nfts(nfts) = self else { return nil }
        return nfts[safe: index]
    }
}
