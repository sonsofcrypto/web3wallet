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
    private let currencyMetadataService: CurrencyMetadataService
    private let web3ServiceLegacy: Web3ServiceLegacy

    init(
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3Service,
        currencyMetadataService: CurrencyMetadataService,
        web3ServiceLegacy: Web3ServiceLegacy
    ) {
        self.alertWireframeFactory = alertWireframeFactory
        self.web3Service = web3Service
        self.currencyMetadataService = currencyMetadataService
        self.web3ServiceLegacy = web3ServiceLegacy
    }
}

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        
        DefaultNetworksWireframe(
            parent: parent,
            web3Service: web3Service,
            currencyMetadataService: currencyMetadataService,
            web3ServiceLegacy: web3ServiceLegacy,
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
                currencyMetadataService: resolver.resolve(),
                web3ServiceLegacy: resolver.resolve()
            )
        }
    }
}