// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol TokenSendInteractor: AnyObject {

    func isAddressValid(
        address: String,
        network: Web3Network
    ) -> Bool
    
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String
}

final class DefaultTokenSendInteractor {

    private let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultTokenSendInteractor: TokenSendInteractor {

    func isAddressValid(
        address: String,
        network: Web3Network
    ) -> Bool {
        
        web3Service.isValid(address: address, forNetwork: network)
    }
    
    func addressFormattedShort(
        address: String,
        network: Web3Network
    ) -> String {
        
        let total = 5

        switch network.name.lowercased() {
            
        case "ethereum":
            return address.prefix(2 + total) + "..." + address.suffix(total)

        default:
            return address.prefix(total) + "..." + address.suffix(total)
        }
    }

}
