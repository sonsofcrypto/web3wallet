// Created by web3d4v on 13/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: - CurrencyReceiveWireframeContext

struct CurrencyReceiveWireframeContext {
    let network: Network
    let currency: Currency
}

// MARK: - CurrencyReceiveWireframeDestination

enum CurrencyReceiveWireframeDestination {}

// MARK: CurrencyReceiveWireframe

protocol CurrencyReceiveWireframe {
    func present()
    func dismiss()
}

// MARK: - DefaultCurrencyReceiveWireframe

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
    
    func dismiss() {
        vc?.popOrDismiss()
    }
}

private extension DefaultCurrencyReceiveWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencyReceiveInteractor(
            networksService: networksService
        )
        let vc: CurrencyReceiveViewController = UIStoryboard(.currencyReceive).instantiate()
        let presenter = DefaultCurrencyReceivePresenter(
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
