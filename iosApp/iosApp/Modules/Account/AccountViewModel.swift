// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

struct AccountViewModel {
    let currencyName: String
    let header: AccountViewModel.Header
    let address: AddressViewModel
    let candles: CandlesViewModel
    let marketInfo: AccountViewModel.MarketInfo
    let bonusAction: AccountViewModel.BonusAction?
    let transactions: [AccountViewModel.Transaction]
}

extension AccountViewModel {

    struct Header {
        let balance: [Formatters.Output]
        let fiatBalance: String
        let pct: String
        let pctUp: Bool
        let buttons: [Button]

        struct Button {
            let title: String
            let imageName: String
        }
    }
}

extension AccountViewModel {

    struct AddressViewModel {
        let address: String
        let copyIcon: String
    }
}

extension AccountViewModel {

    struct MarketInfo {
        let marketCap: String
        let price: String
        let volume: String
    }
}

extension AccountViewModel {

    struct BonusAction {
        let title: String
    }
}

extension AccountViewModel {

    enum Transaction {
        case empty(text: String)
        case loading(text: String)
        case data(Data)
        
        struct Data {
            let date: String
            let address: String
            let amount: String
            let isReceive: Bool
            let txHash: String
        }
        
        var empty: String? {
            switch self {
            case let .empty(text): return text
            default: return nil
            }
        }
        
        var loading: String? {
            switch self {
            case let .loading(text): return text
            default: return nil
            }
        }
        
        var data: Data? {
            switch self {
            case let .data(data): return data
            default: return nil
            }
        }
    }
}
