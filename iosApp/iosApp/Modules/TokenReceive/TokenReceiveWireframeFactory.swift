// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenReceiveWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenReceiveWireframeContext
    ) -> TokenReceiveWireframe
}

final class DefaultTokenReceiveWireframeFactory {

    private let web3Service: Web3ServiceLegacy

    init(
        web3Service: Web3ServiceLegacy
    ) {
        self.web3Service = web3Service
    }
}

extension DefaultTokenReceiveWireframeFactory: TokenReceiveWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenReceiveWireframeContext
    ) -> TokenReceiveWireframe {
        
        DefaultTokenReceiveWireframe(
            presentingIn: presentingIn,
            context: context,
            web3Service: web3Service
        )
    }
}
