// Created by web3d3v on 18/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol NetworkSettingsWireframeFactory {
    func make(_ parent: UIViewController?, network: Network) -> NetworkSettingsWireframe
}

final class DefaultNetworkSettingsWireframeFactory {
    private let networksService: NetworksService

    init(networksService: NetworksService) {
        self.networksService = networksService
    }
}

extension DefaultNetworkSettingsWireframeFactory: NetworkSettingsWireframeFactory {

    func make(_ parent: UIViewController?, network: Network) -> NetworkSettingsWireframe {
        DefaultNetworkSettingsWireframe(
            parent,
            networksService: networksService,
            network: network
        )
    }
}

final class NetworkSettingsWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NetworkSettingsWireframeFactory in
            DefaultNetworkSettingsWireframeFactory(
                networksService: resolver.resolve()
            )
        }
    }
}
