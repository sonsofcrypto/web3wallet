// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenDetailsWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenDetailsWireframeContext
    ) -> TokenDetailsWireframe
}

final class DefaultTokenDetailsWireframeFactory {

    private let web3Service: Web3Service

    init(
        web3Service: Web3Service
    ) {
        self.web3Service = web3Service
    }
}

extension DefaultTokenDetailsWireframeFactory: TokenDetailsWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenDetailsWireframeContext
    ) -> TokenDetailsWireframe {
        
        DefaultTokenDetailsWireframe(
            presentingIn: presentingIn,
            context: context,
            web3Service: web3Service
        )
    }
}
