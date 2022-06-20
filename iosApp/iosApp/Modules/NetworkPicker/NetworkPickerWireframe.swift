// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct NetworkPickerWireframeContext {
    
    let presentationStyle: PresentationStyle
    let onNetworkSelected: (Web3Network) -> Void
}

enum NetworkPickerWireframeDestination {
    
    case select(Web3Network)
}

protocol NetworkPickerWireframe {
    func present()
    func navigate(to destination: NetworkPickerWireframeDestination)
    func dismiss()
}

final class DefaultNetworkPickerWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: NetworkPickerWireframeContext
    private let web3Service: Web3Service
    
    init(
        presentingIn: UIViewController,
        context: NetworkPickerWireframeContext,
        web3Service: Web3Service
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.web3Service = web3Service
    }
}

extension DefaultNetworkPickerWireframe: NetworkPickerWireframe {
    
    func present() {
        
        let vc = wireUp()
        
        switch context.presentationStyle {
            
        case .embed:
            fatalError("This module can't be embedded in a tab bar")
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
            guard let presentingIn = presentingIn as? NavigationController else { return }
            presentingIn.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: NetworkPickerWireframeDestination) {
        
        switch destination {
        case let .select(network):
        
            context.onNetworkSelected(network)
            dismiss()
        }
    }
    
    func dismiss() {
        
        switch context.presentationStyle {
            
        case .embed:
            fatalError("This module can't be embedded in a tab bar")
        
        case .present:
            
            presentingIn.presentedViewController?.dismiss(animated: true)

        case .push:
            
            guard let navigationController = presentingIn as? NavigationController else { return }
            navigationController.popViewController(animated: true)
        }
    }
}

private extension DefaultNetworkPickerWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultNetworkPickerInteractor(
            web3Service: web3Service
        )
        let vc: NetworkPickerViewController = UIStoryboard(.networkPicker).instantiate()
        let presenter = DefaultNetworkPickerPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        
        vc.presenter = presenter
        
        switch context.presentationStyle {
        case .embed:
            
            fatalError("This module can't be embedded in a tab bar")
        case .present, .push:
            
            vc.hidesBottomBarWhenPushed = true
            
            guard !(presentingIn is NavigationController) else { return vc }
            
            let navigationController = NavigationController(rootViewController: vc)
            return navigationController
        }
    }
}
