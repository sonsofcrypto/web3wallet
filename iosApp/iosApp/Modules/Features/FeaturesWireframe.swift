// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum FeaturesWireframeDestination {
    
    case comingSoon
    case feature(feature: Web3Feature, features: [Web3Feature])
}

protocol FeaturesWireframe {
    func present()
    func navigate(to destination: FeaturesWireframeDestination)
}

final class DefaultFeaturesWireframe {

    private weak var parent: UIViewController!
    private let alertWireframeFactory: AlertWireframeFactory
    private let featuresService: FeaturesService

    private weak var vc: UIViewController!

    init(
        parent: UIViewController,
        alertWireframeFactory: AlertWireframeFactory,
        featuresService: FeaturesService
    ) {
        self.parent = parent
        self.alertWireframeFactory = alertWireframeFactory
        self.featuresService = featuresService
    }
}

extension DefaultFeaturesWireframe: FeaturesWireframe {

    func present() {
        
        let vc = wireUp()
        self.vc = vc
        parent.show(vc, sender: self)
    }

    func navigate(to destination: FeaturesWireframeDestination) {

        switch destination {
            
        case let .feature(feature, features):
            
            break
            
        case .comingSoon:
            
            alertWireframeFactory.makeWireframe(
                vc,
                context: .underConstructionAlert()
            ).present()
        }
    }
}

extension DefaultFeaturesWireframe {

    private func wireUp() -> UIViewController {
        
        let vc: FeaturesViewController = UIStoryboard(
            .features
        ).instantiate()
        
        let interactor = DefaultFeaturesInteractor(
            featureService: featuresService
        )
        
        let presenter = DefaultFeaturesPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self
        )

        vc.presenter = presenter
        return vc
    }
}
