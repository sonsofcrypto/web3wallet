// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol SwapInteractor: AnyObject {

    var dapp: DApp { get }
}

// MARK: - DefaultSwapInteractor

class DefaultSwapInteractor {

    let dapp: DApp

    private let service: DegenService

    init(_ dapp: DApp, service: DegenService) {
        self.dapp = dapp
        self.service = service
    }
}

// MARK: - DefaultSwapInteractor

extension DefaultSwapInteractor: SwapInteractor {

}
