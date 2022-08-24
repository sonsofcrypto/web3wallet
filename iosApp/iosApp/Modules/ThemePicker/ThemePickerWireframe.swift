// Created by web3d4v on 24/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ThemePickerWireframe {
    
    func present()
    func navigate(to destination: ThemePickerWireframeDestination)
}

enum ThemePickerWireframeDestination {
 
    case dismiss
}

final class DefaultThemePickerWireframe {

    private weak var presentingIn: UIViewController!
    
    private weak var vc: UIViewController!

    init(
        presentingIn: UIViewController
    ) {
        self.presentingIn = presentingIn
    }
}

extension DefaultThemePickerWireframe: ThemePickerWireframe {

    func present() {
        
        let vc = makeViewController()

        self.vc = vc

        presentingIn.present(vc, animated: false)
    }
    
    func navigate(to destination: ThemePickerWireframeDestination) {
        
        switch destination {
            
        case .dismiss:
            break
        }
    }
}

private extension DefaultThemePickerWireframe {

    func makeViewController() -> UIViewController {
        
        let vc: ThemePickerViewController = UIStoryboard(.dashboard).instantiate()
        vc.modalPresentationStyle = .custom
        return vc
    }
}
