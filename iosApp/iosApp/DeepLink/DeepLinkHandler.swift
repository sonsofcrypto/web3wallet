// Created by web3d4v on 26/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

enum DeepLink: String {
    
    case mnemonicConfirmation = "modal.mnemonic.confirmation"
    case themesList = "settings.themes"
}

protocol DeepLinkHandler: AnyObject {
    
    func handle(deepLink: DeepLink)
}

final class DefaultDeepLinkHandler {
    
    enum DestinationTab {
        
        case settings
    }
}

extension DefaultDeepLinkHandler: DeepLinkHandler {
    
    func handle(deepLink: DeepLink) {

        dismissAnyModals()
        
        switch deepLink {
        case .mnemonicConfirmation:
            break
        case .themesList:
            navigate(to: .settings)
            openThemeMenu()
        }
    }
}

private extension DefaultDeepLinkHandler {
    
    func dismissAnyModals() {
        
        guard let rootVC = SceneDelegateHelper().rootVC else { return }
        
        dismissPresentedVCs(for: rootVC.presentedViewController, animated: false)
    }
    
    func dismissPresentedVCs(
        for viewController: UIViewController?,
        animated: Bool = false
    ) {
        
        if let presentedVC = viewController?.presentedViewController {
            
            dismissPresentedVCs(for: presentedVC)
        }
        
        viewController?.dismiss(animated: animated)
    }
    
    func navigate(to destination: DestinationTab) {
        
        guard let tabBarVC = tabBarController else { return }
        
        switch destination {
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
}
