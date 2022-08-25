// Created by web3d4v on 26/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit
import web3lib

enum DeepLink {
    
    case mnemonicConfirmation
    case themesList
    case featuresList
    case degen
    case cultProposals
    case nftsDashboard
    case account(token: Web3Token)
    
    init?(identifier: String) {
        
        switch identifier {
            
        case DeepLink.mnemonicConfirmation.identifier:
            self = .mnemonicConfirmation
            
        case DeepLink.themesList.identifier:
            self = .themesList
            
        case DeepLink.featuresList.identifier:
            self = .featuresList
            
        case DeepLink.degen.identifier:
            self = .degen

        case DeepLink.cultProposals.identifier:
            self = .cultProposals

        case DeepLink.nftsDashboard.identifier:
            self = .nftsDashboard

        default:
            return nil
        }
    }
    
    var identifier: String {
        
        switch self {
        case .mnemonicConfirmation:
            return "modal.mnemonic.confirmation"
        case .themesList:
            return "settings.themes"
        case .featuresList:
            return "modal.features"
        case .degen:
            return "degen"
        case .cultProposals:
            return "cult.proposals"
        case .nftsDashboard:
            return "nfts.dashboard"
        case let .account(token):
            return "account.\(token.symbol.lowercased())"
        }
    }
}

protocol DeepLinkHandler: AnyObject {
    
    func handle(deepLink: DeepLink)
}

final class DefaultDeepLinkHandler {
    
    enum DestinationTab {
        
        case dashboard
        case degen
        case nfts
        case settings
    }
}

extension DefaultDeepLinkHandler: DeepLinkHandler {
    
    func handle(deepLink: DeepLink) {
        
        let completion: () -> Void = { [weak self] in
            
            guard let self = self else { return }
            
            switch deepLink {
            case .mnemonicConfirmation:
                self.openMnemonicConfirmation()
            case .themesList:
                self.navigate(to: .settings)
                self.openThemeMenu()
            case .featuresList:
                self.openFeaturesList()
            case .degen:
                self.navigate(to: .degen)
            case .cultProposals:
                self.navigate(to: .degen)
                if
                    let degenNavController = self.degenNavController,
                    let vc = degenNavController.viewControllers.first(
                    where: { $0 is CultProposalsViewController }
                ) {
                    degenNavController.popToViewController(vc, animated: true)
                } else {
                    self.openCultProposals()
                }
                
            case .nftsDashboard:
                self.navigate(to: .nfts)
                self.nftsDashboardNavController?.popToRootViewController(animated: true)
                
            case let .account(token):
                self.navigate(to: .dashboard)
                self.dashboardNavController?.popToRootViewController(animated: true)
                self.openAccount(with: token, after: 0.3)
            }
        }

        dismissAnyModals(completion: completion)
    }
}

private extension DefaultDeepLinkHandler {
    
    func dismissAnyModals(
        completion: @escaping (() -> Void)
    ) {
        
        guard let rootVC = SceneDelegateHelper().rootVC else {
            completion()
            return
        }
        
        dismissPresentedVCs(
            for: rootVC.presentedViewController,
            completion: completion,
            animated: true
        )
    }
    
    func dismissPresentedVCs(
        for viewController: UIViewController?,
        completion: @escaping (() -> Void),
        animated: Bool = false
    ) {
        
        if let presentedVC = viewController?.presentedViewController {
            
            dismissPresentedVCs(for: presentedVC, completion: completion)
        }
        
        guard let viewController = viewController else {
            completion()
            return
        }

        viewController.dismiss(animated: animated, completion: completion)
    }
    
    func navigate(to destination: DestinationTab) {
        
        guard let tabBarVC = tabBarController else { return }
        
        switch destination {
        case .dashboard:
            tabBarVC.selectedIndex = 0
        case .degen:
            tabBarVC.selectedIndex = 1
        case .nfts:
            tabBarVC.selectedIndex = 2
        case .settings:
            tabBarVC.selectedIndex = FeatureFlag.showAppsTab.isEnabled ? 4 : 3
        }
    }
}

private extension DefaultDeepLinkHandler {
    
    var tabBarController: TabBarController? {
        
        guard let rootVC = SceneDelegateHelper().rootVC as? RootViewController else { return nil }
        
        return rootVC.children.first(
            where: { $0 is TabBarController }
        ) as? TabBarController
    }
    
    var dashboardNavController: NavigationController? {
        
        guard let navigationController = tabBarController?.children.first(
            where: {
                guard let navigationController = $0 as? NavigationController else {
                    return false
                }
                guard navigationController.viewControllers.first is DashboardViewController else {
                    return false
                }
                return true
            }
        ) as? NavigationController else {
            return nil
        }
        
        return navigationController
    }
    
    var dashboardVC: DashboardViewController? {
        
        dashboardNavController?.topViewController as? DashboardViewController
    }
    
    var degenNavController: NavigationController? {
        
        guard let navigationController = tabBarController?.children.first(
            where: {
                guard let navigationController = $0 as? NavigationController else {
                    return false
                }
                guard navigationController.viewControllers.first is DegenViewController else {
                    return false
                }
                return true
            }
        ) as? NavigationController else {
            return nil
        }
        
        return navigationController
    }
    
    var nftsDashboardNavController: NavigationController? {
        
        guard let navigationController = tabBarController?.children.first(
            where: {
                guard let navigationController = $0 as? NavigationController else {
                    return false
                }
                guard navigationController.viewControllers.first is NFTsDashboardViewController else {
                    return false
                }
                return true
            }
        ) as? NavigationController else {
            return nil
        }
        
        return navigationController
    }
    
    var settingsVC: SettingsViewController? {
        
        guard let navigationController = tabBarController?.children.first(
            where: {
                guard let navigationController = $0 as? NavigationController else {
                    return false
                }
                guard navigationController.topViewController is SettingsViewController else {
                    return false
                }
                return true
            }
        ) as? NavigationController else {
            return nil
        }
        
        return navigationController.topViewController as? SettingsViewController
    }
}

private extension DefaultDeepLinkHandler {
    
    func openThemeMenu() {
        
        guard let settingsVC = settingsVC else { return }
        guard settingsVC.title != Localized("settings.theme") else { return }
        let settingsService: SettingsService = ServiceDirectory.assembler.resolve()
        
        let wireframe: SettingsWireframeFactory = ServiceDirectory.assembler.resolve()
        wireframe.makeWireframe(
            settingsVC,
            context: .init(
                title: Localized("settings.theme"),
                groups: settingsService.settings(for: .theme)
            )
        ).present()
    }
    
    func openFeaturesList() {
        guard let dashboardNavController = dashboardNavController else { return }
        let wireframe: FeaturesWireframeFactory = ServiceDirectory.assembler.resolve()
        wireframe.makeWireframe(
            presentingIn: dashboardNavController,
            context: .init(presentationStyle: .present)
        ).present()
    }
    
    func openMnemonicConfirmation() {
        guard let dashboardNavController = dashboardNavController else { return }
        let wireframe: MnemonicConfirmationWireframeFactory = ServiceDirectory.assembler.resolve()
        wireframe.makeWireframe(dashboardNavController).present()
    }
    
    func openAccount(
        with token: Web3Token,
        after delay: TimeInterval
    ) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self = self else { return }
            self.openAccount(with: token)
        }
    }
    
    func openAccount(
        with token: Web3Token
    ) {
        guard let dashboardNavController = dashboardNavController else { return }
        let service: NetworksService = ServiceDirectory.assembler.resolve()
        guard let wallet = service.wallet(network: token.network.toNetwork()) else { return }
        
        let factory: AccountWireframeFactory = ServiceDirectory.assembler.resolve()
        factory.makeWireframe(
            presentingIn: dashboardNavController,
            context: .init(wallet: wallet, currency: token.toCurrency())
        ).present()
    }
    
    func openCultProposals() {
        guard let degenNavController = degenNavController else { return }
        let factory: CultProposalsWireframeFactory = ServiceDirectory.assembler.resolve()
        factory.makeWireframe(degenNavController).present()
    }
}
