// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct SettingsWireframeContext {
    
    let title: String
    let groups: [Group]
    
    struct Group {
        
        let title: String?
        let items: [Setting]
        let footer: Footer?
        
        struct Footer {
            
            let text: String
            let textAlignment: SettingsViewModel.Section.Footer.TextAlignment
        }
    }
    
    static var `default`: SettingsWireframeContext {
        
        .init(
            title: Localized("settings"),
            groups: [
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.root.themes"),
                            type: .item(.theme)
                        ),
                        .init(
                            title: Localized("settings.root.improvementProposals"),
                            type: .item(
                                item: .improvement,
                                action: .improvementProposals
                            )
                        ),
                        .init(
                            title: Localized("settings.root.developerMenu"),
                            type: .item(.debug)
                        )
                    ],
                    footer: nil
                ),
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.root.about"),
                            type: .item(.about)
                        )
                    ],
                    footer: nil
                ),
                .init(
                    title: nil,
                    items: [
                        .init(
                            title: Localized("settings.root.feedback"),
                            type: .item(
                                item: .feedback,
                                action: .feedbackReport
                            )
                        )
                    ],
                    footer: nil
                )
            ]
        )
    }
}

enum SettingsWireframeDestination {
    
    case dismiss
    case settings(context: SettingsWireframeContext)
}

protocol SettingsWireframe {
    
    func present()
    func navigate(to destination: SettingsWireframeDestination)
}

final class DefaultSettingsWireframe {

    private weak var parent: UIViewController!
    private let context: SettingsWireframeContext
    private let settingsService: SettingsService
    
    private weak var navigationController: NavigationController!

    init(
        parent: UIViewController,
        context: SettingsWireframeContext,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.context = context
        self.settingsService = settingsService
    }
}

extension DefaultSettingsWireframe: SettingsWireframe {

    func present() {
        
        let viewController = wireUp(with: context)

        if let tabBarController = parent as? UITabBarController {
            
            let navController = makeNavigationController(with: viewController)
            let vcs = (tabBarController.viewControllers ?? []) + [navController]
            tabBarController.setViewControllers(vcs, animated: false)
        } else if let navigationController = parent.navigationController as? NavigationController {
            
            self.navigationController = navigationController
            navigationController.pushViewController(viewController, animated: true)
        } else if let navigationController = parent as? NavigationController {

            self.navigationController = navigationController
            navigationController.pushViewController(viewController, animated: true)
        }
    }

    func navigate(to destination: SettingsWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            
            navigationController.popViewController(animated: true)
            
        case let .settings(context):
            
            pushSettingsVC(with: context)
        }
    }
}

private extension DefaultSettingsWireframe {
    
    func pushSettingsVC(with context: SettingsWireframeContext) {
        
        let viewController = wireUp(with: context)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func makeNavigationController(
        with viewController: UIViewController
    ) -> NavigationController {
        
        let navigationController = NavigationController(
            rootViewController: viewController
        )
        
        navigationController.tabBarItem = UITabBarItem(
            title: Localized("settings"),
            image: "tab_icon_settings".assetImage,
            tag: FeatureFlag.showAppsTab.isEnabled ? 4 : 3
        )
        
        self.navigationController = navigationController
        
        return navigationController
    }

    func wireUp(with context: SettingsWireframeContext) -> UIViewController {
        
        let interactor = DefaultSettingsInteractor(
            settingsService
        )
        let vc: SettingsViewController = UIStoryboard(.settings).instantiate()
        let presenter = DefaultSettingsPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        return vc
    }
}
