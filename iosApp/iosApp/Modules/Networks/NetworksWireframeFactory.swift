// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe
}

final class DefaultNetworksWireframeFactory {

    private let alertWireframeFactory: AlertWireframeFactory
    private let walletsConnectionService: WalletsConnectionService
    private let currenciesService: CurrenciesService
    private let currencyMetadataService: CurrencyMetadataService

    init(
        alertWireframeFactory: AlertWireframeFactory,
        walletsConnectionService: WalletsConnectionService,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.alertWireframeFactory = alertWireframeFactory
        self.walletsConnectionService = walletsConnectionService
        self.currenciesService = currenciesService
        self.currencyMetadataService = currencyMetadataService
    }
}

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        
        DefaultNetworksWireframe(
            parent: parent,
            walletsConnectionService: walletsConnectionService,
            currenciesService: currenciesService,
            currencyMetadataService: currencyMetadataService,
            alertWireframeFactory: alertWireframeFactory
        )
    }
}

// MARK: - NetworksWireframeFactoryAssembler

final class NetworksWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NetworksWireframeFactory in
            DefaultNetworksWireframeFactory(
                alertWireframeFactory: resolver.resolve(),
                walletsConnectionService: resolver.resolve(),
                currenciesService: resolver.resolve(),
                currencyMetadataService: resolver.resolve()
            )
        }
    }
}