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
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let web3Service: Web3ServiceLegacy

    init(
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3ServiceLegacy
    ) {
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
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
            tokenPickerWireframeFactory: tokenPickerWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            web3Service: web3Service
        )
    }
}
