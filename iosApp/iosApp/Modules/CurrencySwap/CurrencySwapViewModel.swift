// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CurrencySwapViewModel {
    let title: String
    let items: [Item]
}

extension CurrencySwapViewModel {
    
    enum Item {
        case swap(Swap)
        case limit
    }
    
    struct Swap {
        
        let currencyFrom: CurrencyEnterAmountViewModel
        let currencyTo: CurrencyEnterAmountViewModel
        let currencySwapProviderViewModel: CurrencySwapProviderViewModel
        let currencySwapPriceViewModel: CurrencySwapPriceViewModel
        let currencySwapSlippageViewModel: CurrencySwapSlippageViewModel
        let currencyNetworkFeeViewModel: NetworkFeePickerViewModel
        let isCalculating: Bool
        let providerAsset: String
        let approveState: ApproveState
        let buttonState: ButtonState

        enum ApproveState {
            case approve
            case approving
            case approved
        }
        
        enum ButtonState {
            case loading
            case invalid(text: String)
            case swap
            case swapAnyway(text: String)
        }
    }
}

extension Array where Element == CurrencySwapViewModel.Item {
    var swap: CurrencySwapViewModel.Swap? {
        var swap: CurrencySwapViewModel.Swap?
        forEach { if case let CurrencySwapViewModel.Item.swap(value) = $0 { swap = value } }
        return swap
    }
}
