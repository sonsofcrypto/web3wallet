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
    private weak var parent: UIViewController?
    private let service: MnemonicConfirmationService
    
    private weak var vc: UIViewController?

    init(
        _ parent: UIViewController?,
        service: MnemonicConfirmationService
    ) {
        self.parent = parent
        self.service = service
    }
}

extension DefaultMnemonicConfirmationWireframe: MnemonicConfirmationWireframe {

    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(to destination: MnemonicConfirmationWireframeDestination) {
        switch destination {
        case .dismiss: vc?.popOrDismiss()
        }
    }
}

private extension DefaultMnemonicConfirmationWireframe {

    func wireUp() -> UIViewController {
        let vc: MnemonicConfirmationViewController = UIStoryboard(.mnemonicConfirmation).instantiate()
        let presenter = DefaultMnemonicConfirmationPresenter(
            view: vc,
            wireframe: self,
            service: service
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
