// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenPickerWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenPickerWireframeContext
    ) -> TokenPickerWireframe
}

final class DefaultTokenPickerWireframeFactory {

    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let tokenAddWireframeFactory: TokenAddWireframeFactory
    private let web3Service: Web3Service

    init(
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenAddWireframeFactory: TokenAddWireframeFactory,
        web3Service: Web3Service
    ) {
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenAddWireframeFactory = tokenAddWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultTokenPickerWireframeFactory: TokenPickerWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenPickerWireframeContext
    ) -> TokenPickerWireframe {
        
        DefaultTokenPickerWireframe(
            presentingIn: presentingIn,
            context: context,
            tokenReceiveWireframeFactory: tokenReceiveWireframeFactory,
            tokenAddWireframeFactory: tokenAddWireframeFactory,
            web3Service: web3Service
        )
    }
}
