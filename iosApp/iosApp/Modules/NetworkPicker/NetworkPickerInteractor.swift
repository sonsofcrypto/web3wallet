// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol NetworkPickerInteractor: AnyObject {

    var allNetworks: [ Web3Network ] { get }
    func networkIcon(for network: Web3Network) -> Data
}

final class DefaultNetworkPickerInteractor {

    private let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultNetworkPickerInteractor: NetworkPickerInteractor {
    
    var allNetworks: [Web3Network] {
        
        web3Service.allTokens.networks
    }
    
    func networkIcon(for network: Web3Network) -> Data {
        
        web3Service.networkIcon(for: network)
    }

}
