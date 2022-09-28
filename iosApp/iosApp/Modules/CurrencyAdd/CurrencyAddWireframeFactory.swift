// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - CurrencyAddWireframeFactory

protocol CurrencyAddWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: CurrencyAddWireframeContext
    ) -> CurrencyAddWireframe
}

// MARK: - DefaultCurrencyAddWireframeFactory

final class DefaultCurrencyAddWireframeFactory {
    private let networkPickerWireframeFactory: NetworkPickerWireframeFactory
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let currencyStoreService: CurrencyStoreService

    init(
        networkPickerWireframeFactory: NetworkPickerWireframeFactory,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        currencyStoreService: CurrencyStoreService
    ) {
        self.networkPickerWireframeFactory = networkPickerWireframeFactory
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultCurrencyAddWireframeFactory: CurrencyAddWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: CurrencyAddWireframeContext
    ) -> CurrencyAddWireframe {
        DefaultCurrencyAddWireframe(
            parent,
            context: context,
            networkPickerWireframeFactory: networkPickerWireframeFactory,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            currencyStoreService: currencyStoreService
        )
    }
}

// MARK: - Assembler

final class CurrencyAddWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> CurrencyAddWireframeFactory in
            DefaultCurrencyAddWireframeFactory(
                networkPickerWireframeFactory: resolver.resolve(),
                qrCodeScanWireframeFactory: resolver.resolve(),
                currencyStoreService: resolver.resolve()
            )
        }
    }
}
