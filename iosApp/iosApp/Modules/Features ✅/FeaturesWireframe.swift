// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

// MARK: - FeaturesWireframeDestination

enum FeaturesWireframeDestination {
    case vote(feature: Web3Feature)
    case feature(feature: Web3Feature, features: [Web3Feature])
    case dismiss
}

// MARK: - FeaturesWireframe

protocol FeaturesWireframe {
    func present()
    func navigate(to destination: FeaturesWireframeDestination)
}

// MARK: - DefaultFeaturesWireframe

final class DefaultFeaturesWireframe {
    private weak var parent: UIViewController?
    private let featureWireframeFactory: FeatureWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let featuresService: FeaturesService

    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        featureWireframeFactory: FeatureWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        featuresService: FeaturesService
    ) {
        self.parent = parent
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.featuresService = featuresService
    }
}

extension DefaultFeaturesWireframe: FeaturesWireframe {

    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }

    func navigate(to destination: FeaturesWireframeDestination) {
        switch destination {
        case let .vote(feature):
            FeatureShareHelper().shareVote(feature)
        case let .feature(feature, features):
            let context = FeatureWireframeContext(feature: feature, features: features)
            featureWireframeFactory.make(vc, context: context).present()
        case .dismiss:
            vc?.popOrDismiss()
        }
    }
}

extension DefaultFeaturesWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultFeaturesInteractor(
            featureService: featuresService
        )
        let vc: FeaturesViewController = UIStoryboard(.features).instantiate()
        let presenter = DefaultFeaturesPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor
        )
        vc.presenter = presenter
        self.vc = vc
        guard parent?.asNavigationController == nil else { return vc }
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
