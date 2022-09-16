// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol TokenSwapWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController?,
        context: TokenSwapWireframeContext
    ) -> TokenSwapWireframe
}

final class DefaultTokenSwapWireframeFactory {

    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let web3Service: Web3ServiceLegacy
    private let swapService: UniswapService

    init(
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3ServiceLegacy,
        swapService: UniswapService
    ) {
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.web3Service = web3Service
        self.swapService = swapService
    }
}

extension DefaultTokenSwapWireframeFactory: TokenSwapWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController?,
        context: TokenSwapWireframeContext
    ) -> TokenSwapWireframe {
        
        DefaultTokenSwapWireframe(
            presentingIn: presentingIn!,
            context: context,
            tokenPickerWireframeFactory: tokenPickerWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            web3Service: web3Service,
            swapService: swapService
        )
    }
}
