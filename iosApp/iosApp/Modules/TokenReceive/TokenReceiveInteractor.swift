// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol TokenReceiveInteractor: AnyObject {

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

}
