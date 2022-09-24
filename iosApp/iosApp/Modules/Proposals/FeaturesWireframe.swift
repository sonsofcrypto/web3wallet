// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct FeaturesWireframeContext {
    
    let presentationStyle: PresentationStyle
}

enum FeaturesWireframeDestination {
    
    case vote(feature: ImprovementProposal)
    case feature(feature: ImprovementProposal, features: [ImprovementProposal])
    case dismiss
}

protocol FeaturesWireframe {
    func present()
    func navigate(to destination: FeaturesWireframeDestination)
}

final class DefaultFeaturesWireframe {

    private weak var presentingIn: UIViewController!
    private let context: FeaturesWireframeContext
    private let featureWireframeFactory: FeatureWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let featuresService: ImprovementProposalsService

    private weak var navigationController: NavigationController!

    init(
        presentingIn: UIViewController,
        context: FeaturesWireframeContext,
        featureWireframeFactory: FeatureWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        featuresService: ImprovementProposalsService
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.featureWireframeFactory = featureWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.featuresService = featuresService
    }
}

extension DefaultFeaturesWireframe: FeaturesWireframe {

    func present() {
        
        let vc = wireUp()
        
        switch context.presentationStyle {
            
        case .embed:
            fatalError("Not implemented")
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
            guard let navigationController = presentingIn as? NavigationController else { return }
            self.navigationController = navigationController
            navigationController.pushViewController(vc, animated: true)
        }
    }

    func navigate(to destination: FeaturesWireframeDestination) {

        switch destination {
            
        case let .vote(feature):
            
            FeatureShareHelper().shareVote(on: feature, presentingIn: navigationController)

        case let .feature(feature, features):
            
            featureWireframeFactory.makeWireframe(
                parent: navigationController,
                context: .init(feature: feature, features: features)
            ).present()
            
        case .dismiss:
            
            switch context.presentationStyle {
            case .embed:
                fatalError("Not implemented")
            case .present:
                presentingIn.presentedViewController?.dismiss(animated: true)
            case .push:
                navigationController.popViewController(animated: true)
            }
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
            interactor: interactor,
            wireframe: self
        )
        
        vc.presenter = presenter
        
        switch context.presentationStyle {
        case .embed:
            fatalError("Not implemented")
        case .present:
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController
            
        case .push:
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
}
