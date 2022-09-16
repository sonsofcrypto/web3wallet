// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - FeatureWireframeFactory

protocol FeatureWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: FeatureWireframeContext
    ) -> FeatureWireframe
}

// MARK: - DefaultFeatureWireframeFactory

final class DefaultFeatureWireframeFactory: FeatureWireframeFactory {

    func make(
        _ parent: UIViewController?,
        context: FeatureWireframeContext
    ) -> FeatureWireframe {
        DefaultFeatureWireframe(
            parent: parent,
            context: context
        )
    }
}

// MARK: - Assembler

final class FeatureWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> FeatureWireframeFactory in
            DefaultFeatureWireframeFactory()
        }
    }
}

