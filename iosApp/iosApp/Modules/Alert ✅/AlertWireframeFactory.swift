// Created by web3dgn on 02/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol AlertWireframeFactory {

    func make(_ parent: UIViewController?, context: AlertWireframeContext) -> AlertWireframe
}

final class DefaultAlertWireframeFactory {}

extension DefaultAlertWireframeFactory: AlertWireframeFactory {
    
    func make(_ parent: UIViewController?, context: AlertWireframeContext) -> AlertWireframe {
        DefaultAlertWireframe(parent: parent, context: context)
    }
}

// MARK: - Assembler

final class AlertWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { _ -> AlertWireframeFactory in
            DefaultAlertWireframeFactory()
        }
    }
}

