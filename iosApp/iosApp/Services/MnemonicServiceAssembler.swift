// Created by web3d4v on 21/11/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

final class MnemonicServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { resolver -> MnemonicService in
            DefaultMnemonicService()
        }
    }
}
