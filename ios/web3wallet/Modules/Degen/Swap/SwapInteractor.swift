// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol SwapInteractor: AnyObject {

    var dapp: DApp { get }
}

// MARK: - DefaultSwapInteractor

final class DefaultSwapInteractor {

    let dapp: DApp
    private let degenService: DegenService

    init(dapp: DApp, degenService: DegenService) {
        
        self.dapp = dapp
        self.degenService = degenService
    }
}

// MARK: - DefaultSwapInteractor

extension DefaultSwapInteractor: SwapInteractor {

}
