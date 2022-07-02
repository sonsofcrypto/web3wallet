// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TokenPickerWireframeContext {
    
    let presentationStyle: PresentationStyle
    let source: Source
    
    enum Source {
        
        case receive
        case send
        case multiSelectEdit(
            network: Web3Network?,
            selectedTokens: [Web3Token],
            onCompletion: (([Web3Token]) -> Void)
        )
        
        var localizedValue: String {
            
            switch self {
            case .receive:
                return "receive"
            case .send:
                return "send"
            case .multiSelectEdit:
                return "multiSelectEdit"
            }
        }
        
        var isMultiSelect: Bool {
            
            switch self {
            case .multiSelectEdit:
                return true
            case .receive, .send:
                return false
            }
        }
        
        var network: Web3Network? {
            
            switch self {
            case let .multiSelectEdit(network, _, _):
                return network
            case .receive, .send:
                return nil
            }
        }
    }
}

enum TokenPickerWireframeDestination {
    
    case tokenReceive(Web3Token)
    case tokenSend(Web3Token)
    case addCustomToken
}

protocol TokenPickerWireframe {
    func present()
    func navigate(to destination: TokenPickerWireframeDestination)
    func dismiss()
}

final class DefaultTokenPickerWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: TokenPickerWireframeContext
    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let tokenAddWireframeFactory: TokenAddWireframeFactory
    private let web3Service: Web3Service
    
    init(
        presentingIn: UIViewController,
        context: TokenPickerWireframeContext,
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenAddWireframeFactory: TokenAddWireframeFactory,
        web3Service: Web3Service
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenAddWireframeFactory = tokenAddWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultTokenPickerWireframe: TokenPickerWireframe {
    
    func present() {
        
        let vc = wireUp()
        
        switch context.presentationStyle {
            
        case .embed:
            guard let tabBarController = presentingIn as? TabBarController else {
                return
            }
            let vcs = tabBarController.add(viewController: vc)
            tabBarController.setViewControllers(vcs, animated: false)
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
            guard let presentingIn = presentingIn as? NavigationController else { return }
            presentingIn.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: TokenPickerWireframeDestination) {
        
        switch destination {
        case let .tokenReceive(token):
            
            guard let presentingIn = presentingIn.presentedViewController else { return }
            
            let wireframe = tokenReceiveWireframeFactory.makeWireframe(
                presentingIn: presentingIn,
                context: .init(presentationStyle: .push, web3Token: token)
            )
            wireframe.present()
            
        case let .tokenSend(token):
            
            print("Navigate to send token screen for \(token.symbol)")
            
        case .addCustomToken:
            
            guard let presentingIn = presentingIn.presentedViewController else { return }
            
            let coordinator = tokenAddWireframeFactory.makeWireframe(
                presentingIn: presentingIn,
                context: .init(presentationStyle: .push)
            )
            coordinator.present()
        }
    }
    
    func dismiss() {
        
        presentingIn.presentedViewController?.dismiss(animated: true)
    }
}

private extension DefaultTokenPickerWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultTokenPickerInteractor(
            web3Service: web3Service
        )
        let vc: TokenPickerViewController = UIStoryboard(.tokenPicker).instantiate()
        let presenter = DefaultTokenPickerPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        
        vc.presenter = presenter
        
        switch context.presentationStyle {
        case .embed:
            
            let navigationController = NavigationController(rootViewController: vc)
            navigationController.tabBarItem = UITabBarItem(
                title: Localized("apps"),
                image: UIImage(named: "tab_icon_apps"),
                tag: 3
            )
            return navigationController
        case .present, .push:
            
            vc.hidesBottomBarWhenPushed = true
            
            guard !(presentingIn is NavigationController) else { return vc }
            
            let navigationController = NavigationController(rootViewController: vc)
            return navigationController
        }
    }
}
