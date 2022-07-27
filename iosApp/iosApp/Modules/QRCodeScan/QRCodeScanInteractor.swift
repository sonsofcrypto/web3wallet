// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol QRCodeScanInteractor: AnyObject {

    func validateAddress(address: String, for network: Web3Network) -> String?
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
    
    func validateAddress(address: String, for network: Web3Network) -> String? {
        
        // TODO: @Annon check this is ok. When scanning metamask we get back:
        // eg: "ethereum:0x887jui787dFF1500232E9E2De16d599329C6e65b"
        let address = address.replacingOccurrences(
            of: "\(network.name.lowercased()):",
            with: ""
        )
        
        guard web3Service.isValid(address: address, forNetwork: network) else {
            
            return nil
        }
        
        return address
    }

}
