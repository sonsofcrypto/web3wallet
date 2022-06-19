// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenAddWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenAddWireframeContext
    ) -> TokenAddWireframe
}

final class DefaultTokenAddWireframeFactory {

    private let web3Service: Web3Service

    init(
        web3Service: Web3Service
    ) {
        self.web3Service = web3Service
    }
}

extension DefaultTokenAddWireframeFactory: TokenAddWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenAddWireframeContext
    ) -> TokenAddWireframe {
        
        DefaultTokenAddWireframe(
            presentingIn: presentingIn,
            context: context,
            web3Service: web3Service
        )
    }
}
