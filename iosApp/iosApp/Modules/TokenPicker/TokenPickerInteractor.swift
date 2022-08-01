// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation


protocol TokenPickerInteractor: AnyObject {

    var myTokens: [Web3Token] { get }
    func tokens(
        filteredBy searchTerm: String,
        for network: Web3Network?
    ) -> [Web3Token]
    func networkIcon(for network: Web3Network) -> Data
    func tokenIcon(for token: Web3Token) -> Data
}

final class DefaultTokenPickerInteractor {

    private let web3Service: Web3ServiceLegacy

    init(
        web3Service: Web3ServiceLegacy
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultTokenPickerInteractor: TokenPickerInteractor {
    
    var myTokens: [Web3Token] {
        
        web3Service.myTokens
    }
    
    func tokens(
        filteredBy searchTerm: String,
        for network: Web3Network?
    ) -> [Web3Token] {
        
        web3Service.allTokens.filterBy(searchTerm: searchTerm)
    }
    
    func networkIcon(for network: Web3Network) -> Data {
        
        web3Service.networkIcon(for: network)
    }
    
    func tokenIcon(for token: Web3Token) -> Data {
        
        web3Service.tokenIcon(for: token)
    }

}
