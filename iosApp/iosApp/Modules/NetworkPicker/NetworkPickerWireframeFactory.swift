// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - NetworkPickerWireframeFactory

protocol NetworkPickerWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: NetworkPickerWireframeContext
    ) -> NetworkPickerWireframe
}

// MARK: - DefaultNetworkPickerWireframeFactory

final class DefaultNetworkPickerWireframeFactory {}

extension DefaultNetworkPickerWireframeFactory: NetworkPickerWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: NetworkPickerWireframeContext
    ) -> NetworkPickerWireframe {
        DefaultNetworkPickerWireframe(
            parent,
            context: context
        )
    }
}

// MARK: - Assembler

final class NetworkPickerWireframeFactoryAssembler: AssemblerComponent {
    
    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> NetworkPickerWireframeFactory in
            DefaultNetworkPickerWireframeFactory()
        }
    }
}
