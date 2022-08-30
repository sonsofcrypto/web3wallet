// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol NFTSendWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: NFTSendWireframeContext
    ) -> NFTSendWireframe
}

final class DefaultNFTSendWireframeFactory {

    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let web3Service: Web3ServiceLegacy
    private let networksService: NetworksService

    init(
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3ServiceLegacy,
        networksService: NetworksService
    ) {
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.web3Service = web3Service
        self.networksService = networksService
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
            alertWireframeFactory: alertWireframeFactory,
            web3Service: web3Service,
            networksService: networksService
        )
    }
}
