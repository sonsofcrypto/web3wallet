// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

struct NFTSendViewModel {
    let title: String
    let items: [Item]
}

extension NFTSendViewModel {
    
    struct Fee {
        let id: String
        let name: String
        let value: String
    }
    
    enum Item {
        case address(NetworkAddressPickerViewModel)
        case nft(NFTItem)
        case send(Send)
    }
    
    struct Send {
        let tokenNetworkFeeViewModel: NetworkFeePickerViewModel
        let buttonState: State
        
        enum State {
            case invalidDestination
            case ready
        }
    }
}

extension Array where Element == NFTSendViewModel.Item {
    
    var address: NetworkAddressPickerViewModel? {
        var address: NetworkAddressPickerViewModel?
        forEach {
            if case let NFTSendViewModel.Item.address(value) = $0 {
                address = value
            }
        }
        return address
    }
    
    var nft: NFTItem? {
        var nft: NFTItem?
        forEach {
            if case let NFTSendViewModel.Item.nft(value) = $0 {
                nft = value
            }
        }
        return nft
    }
    
    var send: NFTSendViewModel.Send? {
        var send: NFTSendViewModel.Send?
        forEach {
            if case let NFTSendViewModel.Item.send(value) = $0 {
                send = value
            }
        }
        return send
    }
}
