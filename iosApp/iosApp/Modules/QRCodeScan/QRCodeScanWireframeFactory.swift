// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol QRCodeScanWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: QRCodeScanWireframeContext
    ) -> QRCodeScanWireframe
}

final class DefaultQRCodeScanWireframeFactory {

    private let web3Service: Web3Service

    init(
        web3Service: Web3Service
    ) {
        self.web3Service = web3Service
    }
}

extension DefaultQRCodeScanWireframeFactory: QRCodeScanWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: QRCodeScanWireframeContext
    ) -> QRCodeScanWireframe {
        
        DefaultQRCodeScanWireframe(
            presentingIn: presentingIn,
            context: context,
            web3Service: web3Service
        )
    }
}
