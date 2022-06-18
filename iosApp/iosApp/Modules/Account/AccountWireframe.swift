// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct AccountWireframeContext {
    
    let web3Token: Web3Token
}

enum AccountWireframeDestination {

    case receive
}

protocol AccountWireframe {
    func present()
    func navigate(to destination: AccountWireframeDestination)
}

final class DefaultAccountWireframe {

    private weak var presentingIn: UIViewController?
    private let context: AccountWireframeContext
    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let priceHistoryService: PriceHistoryService
    
    private weak var navigationController: NavigationController!

    init(
        presentingIn: UIViewController,
        context: AccountWireframeContext,
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        priceHistoryService: PriceHistoryService
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.priceHistoryService = priceHistoryService
    }
}

extension DefaultAccountWireframe: AccountWireframe {

    func present() {
        
        let vc = wireUp()
        let topVc = (presentingIn as? UINavigationController)?.topViewController

        if let transitionDelegate =  topVc as? UIViewControllerTransitioningDelegate {
            vc.transitioningDelegate = transitionDelegate
        }

        vc.modalPresentationStyle = .overCurrentContext
        topVc?.show(vc, sender: self)
    }

    func navigate(to destination: AccountWireframeDestination) {

        switch destination {
            
        case .receive:
            
            let coordinator = tokenReceiveWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(presentationStyle: .present, web3Token: context.web3Token)
            )
            coordinator.present()
        }
    }
}

private extension DefaultAccountWireframe {

    func wireUp() -> UIViewController {
        
        let interactor = DefaultAccountInteractor(
            priceHistoryService: priceHistoryService
        )
        
        let vc: AccountViewController = UIStoryboard(.account).instantiate()
        let presenter = DefaultAccountPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        return navigationController
    }
}
