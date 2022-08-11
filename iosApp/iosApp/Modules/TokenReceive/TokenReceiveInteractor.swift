// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol TokenReceiveInteractor: AnyObject {

    func receivingAddress(for token: Web3Token) -> String
}

final class DefaultTokenReceiveInteractor {

    private let web3Service: Web3ServiceLegacy
    
    init(
        web3Service: Web3ServiceLegacy
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultTokenReceiveInteractor: TokenReceiveInteractor {

    func receivingAddress(for token: Web3Token) -> String {
        
        let networksService: NetworksService = ServiceDirectory.assembler.resolve()
        
        guard let address = try? networksService.wallet(network: token.network.toNetwork())?.address() else {
            
            fatalError("Unable to read wallet address from network \(token.network.name)")
        }
        
        return address.toHexStringAddress().hexString
    }
}
