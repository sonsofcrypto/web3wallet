// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol MnemonicConfirmationWireframe {
    
    func present()
    func navigate(to destination: MnemonicConfirmationWireframeDestination)
}

enum MnemonicConfirmationWireframeContext {
    
    case `import`
    case recover
}

enum MnemonicConfirmationWireframeDestination {
    
    case dismiss
}

final class DefaultMnemonicConfirmationWireframe {

    private weak var parent: UIViewController!
    private let service: MnemonicConfirmationService

    init(
        parent: UIViewController,
        service: MnemonicConfirmationService
    ) {
        self.parent = parent
        self.service = service
    }
}

extension DefaultMnemonicConfirmationWireframe: MnemonicConfirmationWireframe {

    func present() {
        
        let vc = makeViewController()
        let navVc = NavigationController(rootViewController: vc)
        parent.present(navVc, animated: true)
    }
    
    func navigate(to destination: MnemonicConfirmationWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            
            parent.presentedViewController?.dismiss(animated: true)
        }
    }
}

private extension DefaultMnemonicConfirmationWireframe {

    func makeViewController() -> UIViewController {
        
        let vc: MnemonicConfirmationViewController = UIStoryboard(.mnemonicConfirmation).instantiate()
        let presenter = DefaultMnemonicConfirmationPresenter(
            view: vc,
            wireframe: self,
            service: service
        )
        vc.presenter = presenter
        return vc
    }
}
