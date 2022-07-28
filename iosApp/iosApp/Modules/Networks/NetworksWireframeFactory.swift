// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe
}

final class DefaultNetworksWireframeFactory {

    private let alertWireframeFactory: AlertWireframeFactory
    private let web3Service: Web3Service

    init(
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3Service
    ) {
        
        self.alertWireframeFactory = alertWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultNetworksWireframeFactory: NetworksWireframeFactory {

    func makeWireframe(_ parent: UIViewController) -> NetworksWireframe {
        
        DefaultNetworksWireframe(
            parent: parent,
            alertWireframeFactory: alertWireframeFactory,
            web3Service: web3Service
        )
    }
}
