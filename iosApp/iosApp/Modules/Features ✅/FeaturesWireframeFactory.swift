// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - FeaturesWireframeFactory

protocol FeaturesWireframeFactory {

    func make(
        _ parent: UIViewController?
    ) -> FeaturesWireframe
}

// MARK: - DefaultFeaturesWireframeFactory

final class DefaultFeaturesWireframeFactory {
    private let featureWireframeFactory: FeatureWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let featuresService: FeaturesService

    init(
        featureWireframeFactory: FeatureWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        featuresService: FeaturesService
    ) {
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.featuresService = featuresService
    }
}

extension DefaultFeaturesWireframeFactory: FeaturesWireframeFactory {

    func make(
        _ parent: UIViewController?
    ) -> FeaturesWireframe {
        DefaultFeaturesWireframe(
            parent,
            featureWireframeFactory: featureWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            featuresService: featuresService
        )
    }
}

// MARK: - Assembler

final class FeaturesWireframeFactoryAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .instance) { resolver -> FeaturesWireframeFactory in
            DefaultFeaturesWireframeFactory(
                featureWireframeFactory: resolver.resolve(),
                alertWireframeFactory: resolver.resolve(),
                featuresService: resolver.resolve()
            )
        }
    }
}

