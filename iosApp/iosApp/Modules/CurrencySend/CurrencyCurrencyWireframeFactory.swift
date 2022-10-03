// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

protocol CurrencyCurrencyWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: CurrencySendWireframeContext
    ) -> CurrencySendWireframe
}

final class DefaultCurrencySendWireframeFactory {
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let currencyPickerWireframeFactory: CurrencyPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService

    init(
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService
    ) {
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.currencyPickerWireframeFactory = currencyPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
    }
}

extension DefaultCurrencySendWireframeFactory: CurrencyCurrencyWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: CurrencySendWireframeContext
    ) -> CurrencySendWireframe {
        DefaultCurrencySendWireframe(
            parent,
            context: context,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            currencyPickerWireframeFactory: currencyPickerWireframeFactory,
            confirmationWireframeFactory: confirmationWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            walletService: walletService,
            networksService: networksService
        )
    }
}

// MARK: - Assembler

final class CurrencySendWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CurrencyCurrencyWireframeFactory in
            DefaultCurrencySendWireframeFactory(
                qrCodeScanWireframeFactory: resolver.resolve(),
                currencyPickerWireframeFactory: resolver.resolve(),
                confirmationWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                walletService: resolver.resolve(),
                networksService: resolver.resolve()
            )
        }
    }
}
