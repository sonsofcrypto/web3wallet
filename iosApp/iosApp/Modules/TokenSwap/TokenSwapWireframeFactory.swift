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

    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let web3Service: Web3Service

    init(
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        web3Service: Web3Service
    ) {
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
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
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            web3Service: web3Service
        )
    }
}
