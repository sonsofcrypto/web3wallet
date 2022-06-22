// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol QRCodeScanInteractor: AnyObject {

    func isValid(address: String, for network: Web3Network) -> Bool
}

final class DefaultQRCodeScanInteractor {

    private let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultQRCodeScanInteractor: QRCodeScanInteractor {
    
    func isValid(address: String, for network: Web3Network) -> Bool {
        
        web3Service.isValid(address: address, forNetwork: network)
    }

}
