// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TokenPickerWireframeContext {
    
    let presentationStyle: PresentationStyle
    let title: TitleKey
    let selectedNetwork: Web3Network?
    let networks: Networks
    let source: Source
    let showAddCustomToken: Bool
    
    // This will be used to construct the view title as: "tokenPicker.title.<titleKey.rawValue>"
    enum TitleKey: String {
        
        case multiSelectEdit = "multiSelectEdit"
        case receive = "receive"
        case send = "send"
        case select = "select"
    }
    
    enum Networks {
        
        case all
        case subgroup(networks: [Web3Network])
    }
    
    enum Source {
        
        case multiSelectEdit(
            selectedTokens: [Web3Token],
            onCompletion: ([Web3Token]) -> Void
        )
        case select(
            onCompletion: (Web3Token) -> Void
        )
                
        var isMultiSelect: Bool {
            
            switch self {
            case .multiSelectEdit:
                return true
            case .select:
                return false
            }
        }
    }
}

enum TokenPickerWireframeDestination {
    
    case addCustomToken(network: Web3Network)
}

protocol TokenPickerWireframe {
    func present()
    func navigate(to destination: TokenPickerWireframeDestination)
    func dismiss()
}

final class DefaultTokenPickerWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: TokenPickerWireframeContext
    private let tokenAddWireframeFactory: TokenAddWireframeFactory
    private let web3Service: Web3ServiceLegacy
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: TokenPickerWireframeContext,
        tokenAddWireframeFactory: TokenAddWireframeFactory,
        web3Service: Web3ServiceLegacy
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.tokenAddWireframeFactory = tokenAddWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultTokenPickerWireframe: TokenPickerWireframe {
    
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
    
    func navigate(to destination: TokenPickerWireframeDestination) {
        
        switch destination {
                        
        case let .addCustomToken(network):
            
            let wireframe = tokenAddWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(
                    presentationStyle: .push,
                    network: network
                )
            )
            wireframe.present()
        }
    }
    
    func dismiss() {
        
        if navigationController.viewControllers.count > 1 {
            
            navigationController.popViewController(animated: true)
        } else {
            
            navigationController.dismiss(animated: true)
        }
    }
}

private extension DefaultTokenPickerWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultTokenPickerInteractor(
            web3ServiceLegacy: web3Service
        )
        let vc: TokenPickerViewController = UIStoryboard(.tokenPicker).instantiate()
        let presenter = DefaultTokenPickerPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        vc.hidesBottomBarWhenPushed = true
        vc.presenter = presenter
        vc.context = context
        
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
