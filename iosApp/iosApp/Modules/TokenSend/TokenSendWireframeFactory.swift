// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSendWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenSendWireframeContext
    ) -> TokenSendWireframe
}

final class DefaultTokenSendWireframeFactory {

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

extension DefaultTokenSendWireframeFactory: TokenSendWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: TokenSendWireframeContext
    ) -> TokenSendWireframe {
        
        DefaultTokenSendWireframe(
            presentingIn: presentingIn,
            context: context,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            web3Service: web3Service
        )
    }
}
