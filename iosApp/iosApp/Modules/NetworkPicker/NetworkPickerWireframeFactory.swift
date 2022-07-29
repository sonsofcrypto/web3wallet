// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworkPickerWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: NetworkPickerWireframeContext
    ) -> NetworkPickerWireframe
}

final class DefaultNetworkPickerWireframeFactory {

    private let web3Service: Web3ServiceLegacy

    init(
        web3Service: Web3ServiceLegacy
    ) {
        self.web3Service = web3Service
    }
}

extension DefaultNetworkPickerWireframeFactory: NetworkPickerWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: NetworkPickerWireframeContext
    ) -> NetworkPickerWireframe {
        
        DefaultNetworkPickerWireframe(
            presentingIn: presentingIn,
            context: context,
            web3Service: web3Service
        )
    }
}
