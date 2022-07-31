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

    private let alertWireframeFactory: AlertWireframeFactory
    private let featuresService: FeaturesService

    init(
        alertWireframeFactory: AlertWireframeFactory,
        featuresService: FeaturesService
    ) {
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
            alertWireframeFactory: alertWireframeFactory,
            featuresService: featuresService
        )
    }
}
