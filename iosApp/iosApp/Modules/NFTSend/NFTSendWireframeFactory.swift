// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - NFTSendWireframeFactory

protocol NFTSendWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: NFTSendWireframeContext
    ) -> NFTSendWireframe
}

// MARK: - DefaultNFTSendWireframeFactory

final class DefaultNFTSendWireframeFactory {
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService

    init(
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultNFTSendWireframeFactory: NFTSendWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: NFTSendWireframeContext
    ) -> NFTSendWireframe {
        DefaultNFTSendWireframe(
            parent,
            context: context,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            networksService: networksService,
            currencyStoreService: currencyStoreService
        )
    }
}

// MARK: - Assember

final class NFTSendWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NFTSendWireframeFactory in
            DefaultNFTSendWireframeFactory(
                qrCodeScanWireframeFactory: resolver.resolve(),
                confirmationWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                networksService: resolver.resolve(),
                currencyStoreService: resolver.resolve()
            )
        }
    }
}

