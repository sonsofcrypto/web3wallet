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

    private let networkPickerWireframeFactory: NetworkPickerWireframeFactory
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let web3Service: Web3ServiceLegacy

    init(
        networkPickerWireframeFactory: NetworkPickerWireframeFactory,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        web3Service: Web3ServiceLegacy
    ) {
        self.networkPickerWireframeFactory = networkPickerWireframeFactory
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
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
            networkPickerWireframeFactory: networkPickerWireframeFactory,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            web3Service: web3Service
        )
    }
}
