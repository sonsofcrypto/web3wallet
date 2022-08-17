// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct DashboardViewModel {
    let shouldAnimateCardSwitcher: Bool
    let sections: [DashboardViewModel.Section]
}

extension DashboardViewModel {

    struct Section {
        let header: Header
        let items: Items
        
        enum Header {
            case balance(String)
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
        let fiatPrice: String
        let fiatBalance: String
        let cryptoBalance: String
        let tokenPrice: String
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
        case .none:
            return false
        case .title, .balance, .network:
            return true
        }
    }

    var isCollapsed: Bool {
        switch header {
        case let .network(network):
            return network.isCollapsed
        default:
            return false
        }
    }
    
    var networkId: String {
        switch header {
        case let .network(network):
            return network.id
        default:
            return ""
        }
    }
}

extension DashboardViewModel.Section.Items {
    
    var count: Int {
        switch self {
        case .actions:
            return 1
        case let .notifications(notifications):
            return notifications.count
        case let .wallets(wallets):
            return wallets.count
        case let .nfts(nfts):
            return nfts.count
        }
    }
    
    var actions: [DashboardViewModel.Action] {
        guard case let DashboardViewModel.Section.Items.actions(
            actions
        ) = self else { return [] }
        return actions
    }
    
    func notifications(at index: Int) -> DashboardViewModel.Notification? {
        guard case let DashboardViewModel.Section.Items.notifications(
            notifications
        ) = self else { return nil }
        return notifications[safe: index]
    }
    
    func wallet(at index: Int) -> DashboardViewModel.Wallet? {
        
        guard case let DashboardViewModel.Section.Items.wallets(
            wallets
        ) = self else { return nil }
        return wallets[safe: index]
    }

    func nft(at index: Int) -> DashboardViewModel.NFT? {
        
        guard case let DashboardViewModel.Section.Items.nfts(
            nfts
        ) = self else { return nil }
        return nfts[safe: index]
    }
}
