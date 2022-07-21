// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSwapWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenSwapWireframeContext
    ) -> TokenSwapWireframe
}

final class DefaultTokenSwapWireframeFactory {

    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let web3Service: Web3Service

    init(
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        web3Service: Web3Service
    ) {
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultTokenSwapWireframeFactory: TokenSwapWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenSwapWireframeContext
    ) -> TokenSwapWireframe {
        
        DefaultTokenSwapWireframe(
            presentingIn: presentingIn,
            context: context,
            tokenPickerWireframeFactory: tokenPickerWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            web3Service: web3Service
        )
    }
}
