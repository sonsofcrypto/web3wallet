// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: TokenReceiveWireframeContext

struct TokenReceiveWireframeContext {
    let network: Network
    let currency: Currency
}

// MARK: TokenReceiveWireframeDestination

enum TokenReceiveWireframeDestination {}

// MARK: TokenReceiveWireframe

protocol TokenReceiveWireframe {
    func present()
    func dismiss()
}

// MARK: DefaultTokenReceiveWireframe

final class DefaultTokenReceiveWireframe {
    private weak var parent: UIViewController?
    private let context: TokenReceiveWireframeContext
    private let networksService: NetworksService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: TokenReceiveWireframeContext,
        networksService: NetworksService
    ) {
        self.parent = parent
        self.context = context
        self.networksService = networksService
    }
}

extension DefaultTokenReceiveWireframe: TokenReceiveWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func dismiss() {
        if let nc = vc?.navigationController as? NavigationController {
            nc.popViewController(animated: true)
        } else {
            vc?.dismiss(animated: true)
        }
    }
}

private extension DefaultTokenReceiveWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultTokenReceiveInteractor(
            networksService: networksService
        )
        let vc: TokenReceiveViewController = UIStoryboard(.tokenReceive).instantiate()
        let presenter = DefaultTokenReceivePresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
