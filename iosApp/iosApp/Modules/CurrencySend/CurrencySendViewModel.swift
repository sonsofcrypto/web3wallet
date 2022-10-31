// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct CurrencySendViewModel {
    let title: String
    let items: [Item]
}

extension CurrencySendViewModel {
    
    struct Fee {
        let id: String
        let name: String
        let value: String
    }
    
    enum Item {
        case address(NetworkAddressPickerViewModel)
        case token(CurrencyAmountPickerViewModel)
        case send(Send)
    }

    struct Send {
        let networkFeeViewModel: NetworkFeeViewModel
        let buttonState: State
        
        enum State {
            case invalidDestination
            case enterFunds
            case insufficientFunds
            case ready
        }
    }
}

extension Array where Element == CurrencySendViewModel.Item {
    var address: NetworkAddressPickerViewModel? {
        var address: NetworkAddressPickerViewModel?
        forEach {
            if case let CurrencySendViewModel.Item.address(value) = $0 {
                address = value
            }
        }
        return address
    }
    
    var token: CurrencyAmountPickerViewModel? {
        var token: CurrencyAmountPickerViewModel?
        forEach {
            if case let CurrencySendViewModel.Item.token(value) = $0 {
                token = value
            }
        }
        return token
    }
    
    var send: CurrencySendViewModel.Send? {
        var send: CurrencySendViewModel.Send?
        forEach {
            if case let CurrencySendViewModel.Item.send(value) = $0 {
                send = value
            }
        }
        return send
    }
}
