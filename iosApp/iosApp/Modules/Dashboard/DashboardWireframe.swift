// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

enum DashboardWireframeDestination {
    case wallet(wallet: KeyStoreItem, token: Token)
    case keyStoreNetworkSettings
    case presentUnderConstructionAlert
    case mnemonicConfirmation
}

protocol DashboardWireframe {
    func present()
    func navigate(to destination: DashboardWireframeDestination)
}

final class DefaultDashboardWireframe {

    private weak var parent: UIViewController!
    private weak var vc: UIViewController!

    private let keyStoreService: KeyStoreService
    private let accountWireframeFactory: AccountWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory
    private let onboardingService: OnboardingService

    init(
        parent: UIViewController,
        keyStoreService: KeyStoreService,
        accountWireframeFactory: AccountWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        mnemonicConfirmationWireframeFactory: MnemonicConfirmationWireframeFactory,
        onboardingService: OnboardingService
    ) {
        self.parent = parent
        self.keyStoreService = keyStoreService
        self.accountWireframeFactory = accountWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.mnemonicConfirmationWireframeFactory = mnemonicConfirmationWireframeFactory
        self.onboardingService = onboardingService
    }
}

extension DefaultDashboardWireframe: DashboardWireframe {

    func present() {
        
        vc = wireUp()
        
        if let parent = parent as? EdgeCardsController {
            
            parent.setMaster(vc: vc)
        
        } else if let tabVc = parent as? UITabBarController {
            
            let vcs: [UIViewController] = [vc] + (tabVc.viewControllers ?? [])
            tabVc.setViewControllers(vcs, animated: false)
            
        } else {
            parent.show(vc, sender: self)
        }
    }

    func navigate(to destination: DashboardWireframeDestination) {
        guard let vc = self.vc ?? parent else {
            print("DefaultDashboardWireframe has no view")
            return
        }

        switch destination {
            
        case let .wallet(wallet, token):
            accountWireframeFactory.makeWireframe(vc, wallet: wallet, token: token).present()
            
        case .keyStoreNetworkSettings:
            vc.edgeCardsController?.setDisplayMode(.overview, animated: true)
            
        case .presentUnderConstructionAlert:
            
            let context = AlertContext.underConstructionAlert()
            alertWireframeFactory.makeWireframe(parent, context: context).present()
            
        case .mnemonicConfirmation:
            
            mnemonicConfirmationWireframeFactory.makeWireframe(parent).present()
        }
    }
}

private extension DefaultDashboardWireframe {

    func wireUp() -> UIViewController {
        
        let interactor = DefaultDashboardInteractor(keyStoreService)
        let vc: DashboardViewController = UIStoryboard(.main).instantiate()
        let presenter = DefaultDashboardPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            onboardingService: onboardingService
        )

        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
