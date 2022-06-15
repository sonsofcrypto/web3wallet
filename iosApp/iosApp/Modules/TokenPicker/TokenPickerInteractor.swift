// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol TokenPickerInteractor: AnyObject {

    var allNetworks: [ Web3Network ] { get }
    func tokens(matching: String) -> [ Web3Token ]
}

final class DefaultTokenPickerInteractor {

    private let web3Service: Web3Service
    
    init(
        web3Service: Web3Service
    ) {
        
        self.web3Service = web3Service
    }
}

extension DefaultTokenPickerInteractor: TokenPickerInteractor {
    
    var allNetworks: [ Web3Network ] {
        
        web3Service.allNetworks
    }

    func tokens(matching searchTerm: String) -> [ Web3Token ] {
        
        let currencies = web3Service.allTokens
        
        return currencies.filter {
            
            guard !searchTerm.isEmpty else { return true }
            return $0.name.capitalized.hasPrefix(searchTerm.capitalized) || $0.symbol.capitalized.hasPrefix(searchTerm.capitalized)
        }
    }
}
