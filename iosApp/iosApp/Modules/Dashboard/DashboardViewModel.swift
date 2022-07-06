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
        
        let name: String
        let fuelCost: String?
        let rightActionTitle: String?
        let isCollapsed: Bool?
        let items: Items
        
        enum Items {
            
            case actions([DashboardViewModel.Action])
            case wallets([DashboardViewModel.Wallet])
            case nfts([DashboardViewModel.NFT])
            
            var count: Int {
                
                switch self {
                case .actions:
                    return 1
                case let .wallets(wallets):
                    return wallets.count
                case let .nfts(nfts):
                    return nfts.count
                }
            }
            
            func actions() -> [DashboardViewModel.Action] {
                
                guard case let Items.actions(actions) = self else { return [] }
                
                return actions
            }
            
            func wallet(at index: Int) -> DashboardViewModel.Wallet? {
                
                guard case let Items.wallets(wallets) = self else { return nil }
                
                guard wallets.count > index else { return nil }
                
                return wallets[index]
            }

            func nft(at index: Int) -> DashboardViewModel.NFT? {
                
                guard case let Items.nfts(nfts) = self else { return nil }
                
                guard nfts.count > index else { return nil }
                
                return nfts[index]
            }
        }
    }
}

extension DashboardViewModel {

    struct Wallet {
        
        let name: String
        let ticker: String
        let imageData: Data
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
