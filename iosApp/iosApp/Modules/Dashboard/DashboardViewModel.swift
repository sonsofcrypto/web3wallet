// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct DashboardViewModel {
    
    let shouldAnimateCardSwitcher: Bool
    let header: DashboardViewModel.Header
    let sections: [DashboardViewModel.Section]
}

extension DashboardViewModel {

    struct Header {
        let balance: String
        let pct: String
        let pctUp: Bool
        let buttons: [DashboardViewModel.Header.Button]
        let firstSection: String?

        struct Button {
            let title: String
            let imageName: String
        }
    }
}

extension DashboardViewModel {

    struct Section {
        let name: String
        let items: Items
        
        enum Items {
            
            case wallets([DashboardViewModel.Wallet])
            case nfts([DashboardViewModel.NFT])
            
            var count: Int {
                
                switch self {
                case let .wallets(wallets):
                    return wallets.count
                case let .nfts(nfts):
                    return nfts.count
                }
            }
            
            func wallet(at index: Int) -> DashboardViewModel.Wallet? {
                
                guard case let Items.wallets(wallets) = self else { return nil }
                
                return wallets[index]
            }

            func nft(at index: Int) -> DashboardViewModel.NFT? {
                
                guard case let Items.nfts(nfts) = self else { return nil }
                
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
