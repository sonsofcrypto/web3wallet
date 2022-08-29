// Created by web3d4v on 29/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

final class MailServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> MailService in
            DefaultMailService()
        }
    }
}
