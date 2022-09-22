// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol FeaturesWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: FeaturesWireframeContext
    ) -> FeaturesWireframe
}

final class DefaultFeaturesWireframeFactory {

    private let featureWireframeFactory: FeatureWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let featuresService: ImprovementProposalsService

    init(
        featureWireframeFactory: FeatureWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        featuresService: ImprovementProposalsService
    ) {
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.featuresService = featuresService
    }
}

extension DefaultFeaturesWireframeFactory: FeaturesWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: FeaturesWireframeContext
    ) -> FeaturesWireframe {
        
        DefaultFeaturesWireframe(
            presentingIn: presentingIn,
            context: context,
            featureWireframeFactory: featureWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            featuresService: featuresService
        )
    }
}
