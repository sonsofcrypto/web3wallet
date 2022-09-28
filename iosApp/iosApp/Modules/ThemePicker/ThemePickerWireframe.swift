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
    private weak var parent: UIViewController?
    
    private weak var vc: UIViewController?

    init(_ parent: UIViewController?) {
        self.parent = parent
    }
}

extension DefaultThemePickerWireframe: ThemePickerWireframe {

    func present() {
        let vc = makeViewController()
        parent?.present(vc, animated: false)
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
        self.vc = vc
        return vc
    }
}
