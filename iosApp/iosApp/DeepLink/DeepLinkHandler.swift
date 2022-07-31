// Created by web3d4v on 26/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum DeepLink: String {
    
    case mnemonicConfirmation = "modal.mnemonic.confirmation"
    case themesList = "settings.themes"
    case featuresList = "modal.features"
    case degen = "degen"
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
            
            tabBarVC.selectedIndex = 3
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
    
    var dashboardVC: DashboardViewController? {
        
        guard let navigationController = tabBarController?.children.first(
            where: {
                guard let navigationController = $0 as? NavigationController else {
                    return false
                }
                guard navigationController.topViewController is DashboardViewController else {
                    return false
                }
                return true
            }
        ) as? NavigationController else {
            return nil
        }
        
        return navigationController.topViewController as? DashboardViewController
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
                groups: [
                    .init(
                        title: nil,
                        items: settingsService.settings(for: .theme)
                    )
                ]
            )
        ).present()
    }
    
    func openFeaturesList() {
        
        guard let dashboardVC = dashboardVC else { return }
        let wireframe: FeaturesWireframeFactory = ServiceDirectory.assembler.resolve()
        wireframe.makeWireframe(
            presentingIn: dashboardVC,
            context: .init(presentationStyle: .present)
        ).present()
    }
    
    func openMnemonicConfirmation() {
        
        guard let dashboardVC = dashboardVC else { return }
        let wireframe: MnemonicConfirmationWireframeFactory = ServiceDirectory.assembler.resolve()
        wireframe.makeWireframe(dashboardVC).present()
    }
}
