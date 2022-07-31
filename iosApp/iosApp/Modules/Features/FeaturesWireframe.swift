// Created by web3d3v on 30/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct FeaturesWireframeContext {
    
    let presentationStyle: PresentationStyle
}

enum FeaturesWireframeDestination {
    
    case comingSoon
    case feature(feature: Web3Feature, features: [Web3Feature])
}

protocol FeaturesWireframe {
    func present()
    func navigate(to destination: FeaturesWireframeDestination)
}

final class DefaultFeaturesWireframe {

    private weak var presentingIn: UIViewController!
    private let context: FeaturesWireframeContext
    private let alertWireframeFactory: AlertWireframeFactory
    private let featuresService: FeaturesService

    private weak var navigationController: NavigationController!

    init(
        presentingIn: UIViewController,
        context: FeaturesWireframeContext,
        alertWireframeFactory: AlertWireframeFactory,
        featuresService: FeaturesService
    ) {
        self.presentingIn = presentingIn
        self.context = context
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
            guard let presentingIn = presentingIn as? NavigationController else { return }
            presentingIn.pushViewController(vc, animated: true)
        }
    }

    func navigate(to destination: FeaturesWireframeDestination) {

        switch destination {
            
        case let .feature(feature, features):
            
            break
            
        case .comingSoon:
            
            alertWireframeFactory.makeWireframe(
                navigationController,
                context: .underConstructionAlert()
            ).present()
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
            return navigationController
            
        case .push:
            
            vc.hidesBottomBarWhenPushed = true
            return vc
        }
    }
}
