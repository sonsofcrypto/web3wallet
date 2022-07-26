// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct TokenSwapWireframeContext {
    
    let presentationStyle: PresentationStyle
    let tokenFrom: Web3Token?
    let tokenTo: Web3Token?
}

enum TokenSwapWireframeDestination {
    
    case selectMyToken(onCompletion: (Web3Token) -> Void)
    case selectToken(onCompletion: (Web3Token) -> Void)
    case confirmSwap(
        dataIn: ConfirmationWireframeContext.SwapContext,
        onSuccess: () -> Void
    )
}

protocol TokenSwapWireframe {
    func present()
    func navigate(to destination: TokenSwapWireframeDestination)
    func dismiss()
}

final class DefaultTokenSwapWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: TokenSwapWireframeContext
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let web3Service: Web3Service
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: TokenSwapWireframeContext,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        web3Service: Web3Service
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.web3Service = web3Service
    }
}

extension DefaultTokenSwapWireframe: TokenSwapWireframe {
    
    func present() {
        
        let vc = wireUp()
        
        switch context.presentationStyle {
            
        case .embed:
            fatalError("This module should not be presented embedded")
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
            guard let presentingIn = presentingIn as? NavigationController else { return }
            presentingIn.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: TokenSwapWireframeDestination) {
        
        switch destination {
            
        case let .selectMyToken(onCompletion):
            presentTokenPicker(with: .myToken, onCompletion: onCompletion)
            
        case let .selectToken(onCompletion):
            presentTokenPicker(with: .any, onCompletion: onCompletion)
        
        case let .confirmSwap(dataIn, onSuccess):
            
            guard let viewController = navigationController.topViewController else {
                
                return
            }
            
            let wireframe = confirmationWireframeFactory.makeWireframe(
                presentingIn: viewController,
                context: .init(type: .swap(dataIn), onSuccessHandler: onSuccess)
            )
            wireframe.present()
        }
    }
    
    func dismiss() {
        
        if navigationController.viewControllers.count == 1 {
            
            navigationController.dismiss(animated: true)
        } else {
            navigationController.popViewController(animated: true)
        }
    }
}

private extension DefaultTokenSwapWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultTokenSwapInteractor(
            web3Service: web3Service
        )
        let vc: TokenSwapViewController = UIStoryboard(.tokenSwap).instantiate()
        let presenter = DefaultTokenSwapPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        
        vc.presenter = presenter
        
        switch context.presentationStyle {
        case .embed:
            
            fatalError("This module should not be presented embedded")
        case .present:

            vc.hidesBottomBarWhenPushed = true
            
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController

        case .push:
            
            vc.hidesBottomBarWhenPushed = true
            
            if let navigationController = presentingIn as? NavigationController {
                
                self.navigationController = navigationController
                return vc
            }
            
            let navigationController = NavigationController(rootViewController: vc)
            self.navigationController = navigationController
            return navigationController
        }
    }
    
    func presentTokenPicker(
        with type: TokenPickerWireframeContext.Source.SelectionType,
        onCompletion: @escaping (Web3Token) -> Void
    ) {
        
        let wireframe = tokenPickerWireframeFactory.makeWireframe(
            presentingIn: navigationController,
            context: .init(
                presentationStyle: .present,
                source: .select(
                    type: type,
                    onCompletion: onCompletion
                )
            )
        )
        wireframe.present()
    }
}