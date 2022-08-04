// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTSendWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: NFTSendWireframeContext
    ) -> NFTSendWireframe
}

final class DefaultNFTSendWireframeFactory {

    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let web3Service: Web3ServiceLegacy

    init(
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        web3Service: Web3ServiceLegacy
    ) {
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultNFTSendWireframeFactory: NFTSendWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: NFTSendWireframeContext
    ) -> NFTSendWireframe {
        
        DefaultNFTSendWireframe(
            presentingIn: presentingIn,
            context: context,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            web3Service: web3Service
        )
    }
}
