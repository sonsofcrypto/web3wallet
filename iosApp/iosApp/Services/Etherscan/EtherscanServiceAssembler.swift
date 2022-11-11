// Created by web3d4v on 05/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

final class EtherscanServiceAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        
        registry.register(scope: .singleton) { resolver -> EtherScanService in
            DefaultEtherScanService(
                store: KeyValueStore(name: "\(EtherScanService.self)")
            )
        }
    }
}
