// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultCurrencyReceiveWireframe {
    private weak var parent: UIViewController?
    private let context: CurrencyReceiveWireframeContext
    private let networksService: NetworksService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencyReceiveWireframeContext,
        networksService: NetworksService
    ) {
        self.parent = parent
        self.context = context
        self.networksService = networksService
    }
}

extension DefaultCurrencyReceiveWireframe: CurrencyReceiveWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(destination_______ destination: CurrencyReceiveWireframeDestination) {
        if (destination as? CurrencyReceiveWireframeDestination.Dismiss) != nil {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultCurrencyReceiveWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencyReceiveInteractor(networksService: networksService)
        let vc: CurrencyReceiveViewController = UIStoryboard(.currencyReceive).instantiate()
        let presenter = DefaultCurrencyReceivePresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
}
