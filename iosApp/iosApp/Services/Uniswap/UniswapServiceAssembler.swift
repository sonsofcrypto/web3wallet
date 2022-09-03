// Created by web3d3v on 03/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class UniswapServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { _ -> UniswapService in
            DefaultUniswapService()
        }
    }
}
