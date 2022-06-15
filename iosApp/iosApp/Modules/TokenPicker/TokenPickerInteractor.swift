// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol TokenPickerInteractor: AnyObject {

    var allNetworks: [ Web3Network ] { get }
    var allTokens: [ Web3Token ] { get }
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

    var allTokens: [ Web3Token ] {
        
        web3Service.allTokens
    }
}
