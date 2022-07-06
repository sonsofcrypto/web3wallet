// Created by web3d4v on 21/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

struct QRCodeScanWireframeContext {
    
    let presentationStyle: PresentationStyle
    let type: `Type`
    let onCompletion: (String) -> Void

    enum `Type` {
        case `default`
        case network(Web3Network)
    }
}

enum QRCodeScanWireframeDestination {
    
    case qrCode(String)
}

protocol QRCodeScanWireframe {
    func present()
    func navigate(to destination: QRCodeScanWireframeDestination)
    func dismiss()
}

final class DefaultQRCodeScanWireframe {
    
    private weak var presentingIn: UIViewController!
    private let context: QRCodeScanWireframeContext
    private let web3Service: Web3Service
    
    private weak var navigationController: NavigationController!
    
    init(
        presentingIn: UIViewController,
        context: QRCodeScanWireframeContext,
        web3Service: Web3Service
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.web3Service = web3Service
    }
}

extension DefaultQRCodeScanWireframe: QRCodeScanWireframe {
    
    func present() {
        
        let vc = wireUp()
        
        switch context.presentationStyle {
            
        case .embed:
            fatalError("This module can't be embedded in a tab bar")
            
        case .present:
            presentingIn.present(vc, animated: true)
            
        case .push:
            guard let presentingIn = presentingIn as? NavigationController else { return }
            self.navigationController = presentingIn
            presentingIn.pushViewController(vc, animated: true)
        }
    }
    
    func navigate(to destination: QRCodeScanWireframeDestination) {
        
        switch destination {
        case let .qrCode(qrCode):
            
            context.onCompletion(qrCode)
            dismiss()
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

private extension DefaultQRCodeScanWireframe {
    
    func wireUp() -> UIViewController {
        
        let interactor = DefaultQRCodeScanInteractor(
            web3Service: web3Service
        )
        let vc: QRCodeScanViewController = UIStoryboard(.qrCodeScan).instantiate()
        let presenter = DefaultQRCodeScanPresenter(
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
            self.navigationController = navigationController
            return navigationController
        }
    }
}
