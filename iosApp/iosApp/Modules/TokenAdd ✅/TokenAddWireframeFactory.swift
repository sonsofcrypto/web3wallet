// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - TokenAddWireframeFactory

protocol TokenAddWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: TokenAddWireframeContext
    ) -> TokenAddWireframe
}

// MARK: - DefaultTokenAddWireframeFactory

final class DefaultTokenAddWireframeFactory {
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

extension DefaultTokenAddWireframeFactory: TokenAddWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: TokenAddWireframeContext
    ) -> TokenAddWireframe {
        DefaultTokenAddWireframe(
            parent,
            context: context,
            networkPickerWireframeFactory: networkPickerWireframeFactory,
            qrCodeScanWireframeFactory: qrCodeScanWireframeFactory,
            currencyStoreService: currencyStoreService
        )
    }
}

// MARK: - Assembler

final class TokenAddWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> TokenAddWireframeFactory in
            DefaultTokenAddWireframeFactory(
                networkPickerWireframeFactory: resolver.resolve(),
                qrCodeScanWireframeFactory: resolver.resolve(),
                currencyStoreService: resolver.resolve()
            )
        }
    }
}
