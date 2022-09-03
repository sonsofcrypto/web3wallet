// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct TokenSwapWireframeContext {
    
    let presentationStyle: PresentationStyle
    let tokenFrom: Web3Token?
    let tokenTo: Web3Token?
}

enum TokenSwapWireframeDestination {
    
    case underConstructionAlert
    case selectMyToken(
        selectedToken: Web3Token,
        onCompletion: (Web3Token) -> Void
    )
    case selectToken(
        selectedToken: Web3Token,
        onCompletion: (Web3Token) -> Void
    )
    case confirmSwap(
        dataIn: ConfirmationWireframeContext.SwapContext
    )
    case confirmApproval(
        iconName: String,
        token: Web3Token,
        onApproved: ((password: String, salt: String)) -> Void
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
    private let alertWireframeFactory: AlertWireframeFactory
    private let web3Service: Web3ServiceLegacy
    private let swapService: UniswapService
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: TokenSwapWireframeContext,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        web3Service: Web3ServiceLegacy,
        swapService: UniswapService
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.web3Service = web3Service
        self.swapService = swapService
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
            
        case .underConstructionAlert:
            guard let viewController = navigationController.topViewController else {
                return
            }
            alertWireframeFactory.makeWireframe(
                viewController,
                context: .underConstructionAlert()
            ).present()
            
        case let .selectMyToken(selectedToken, onCompletion):
            presentTokenPicker(selectedToken: selectedToken, onCompletion: onCompletion)
            
        case let .selectToken(selectedToken, onCompletion):
            presentTokenPicker(selectedToken: selectedToken, onCompletion: onCompletion)
        
        case let .confirmSwap(dataIn):
            guard let viewController = navigationController.topViewController else {
                return
            }
            let wireframe = confirmationWireframeFactory.makeWireframe(
                presentingIn: viewController,
                context: .init(type: .swap(dataIn))
            )
            wireframe.present()
            
        case let .confirmApproval(iconName, token, onApproved):
            guard let viewController = navigationController.topViewController else {
                return
            }
            let wireframe = confirmationWireframeFactory.makeWireframe(
                presentingIn: viewController,
                context: .init(
                    type: .approveUniswap(
                        .init(
                            iconName: iconName,
                            token: token,
                            onApproved: onApproved
                        )
                    )
                )
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
            web3Service: web3Service,
            swapService: swapService
        )
        let vc: TokenSwapViewController = UIStoryboard(.tokenSwap).instantiate()
        let presenter = DefaultTokenSwapPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        vc.hidesBottomBarWhenPushed = true
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
        selectedToken: Web3Token,
        onCompletion: @escaping (Web3Token) -> Void
    ) {
        
        let wireframe = tokenPickerWireframeFactory.makeWireframe(
            presentingIn: navigationController,
            context: .init(
                presentationStyle: .present,
                title: .select,
                selectedNetwork: selectedToken.network,
                networks: .all,
                source: .select(
                    onCompletion: makeOnCompletionDismissWrapped(with: onCompletion)
                ),
                showAddCustomToken: false
            )
        )
        wireframe.present()
    }
    
    func makeOnCompletionDismissWrapped(
        with onCompletion: @escaping (Web3Token) -> Void
    ) -> (Web3Token) -> Void {
        
        {
            [weak self] selectedToken in
            guard let self = self else { return }
            onCompletion(selectedToken)
            self.navigationController.presentedViewController?.dismiss(animated: true)
        }
    }
}
