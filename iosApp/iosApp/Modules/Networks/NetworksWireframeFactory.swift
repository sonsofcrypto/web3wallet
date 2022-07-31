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
    private let web3Service: Web3Service
    private let currenciesService: CurrenciesService
    private let currencyMetadataService: CurrencyMetadataService

    init(
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3Service,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.alertWireframeFactory = alertWireframeFactory
        self.web3Service = web3Service
        self.currenciesService = currenciesService
        self.currencyMetadataService = currencyMetadataService
    }
}

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        
        DefaultNetworksWireframe(
            parent: parent,
            web3Service: web3Service,
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
                web3Service: resolver.resolve(),
                currenciesService: resolver.resolve(),
                currencyMetadataService: resolver.resolve()
            )
        }
    }
}