// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: QRCodeScanWireframeFactory

protocol QRCodeScanWireframeFactory {
    func make(
        _ parent: UIViewController?,
        context: QRCodeScanWireframeContext
    ) -> QRCodeScanWireframe
}

// MARK: DefaultQRCodeScanWireframeFactory

final class DefaultQRCodeScanWireframeFactory {}

extension DefaultQRCodeScanWireframeFactory: QRCodeScanWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: QRCodeScanWireframeContext
    ) -> QRCodeScanWireframe {
        DefaultQRCodeScanWireframe(
            parent,
            context: context
        )
    }
}

// MARK: Assembler

final class QRCodeScanWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> QRCodeScanWireframeFactory in
            DefaultQRCodeScanWireframeFactory()
        }
    }
}
