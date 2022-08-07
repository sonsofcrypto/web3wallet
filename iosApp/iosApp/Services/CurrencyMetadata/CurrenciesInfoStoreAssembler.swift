// Created by web3d3v on 06/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

final class CurrenciesInfoStoreAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { _ -> CurrenciesInfoStore in
            DefaultCurrenciesInfoStore()
        }
    }
}