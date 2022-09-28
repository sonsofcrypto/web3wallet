// Created by web3d4v on 26/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class DeepLinkHandlerAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { _ -> DeepLinkHandler in
            DefaultDeepLinkHandler()
        }
    }
}
