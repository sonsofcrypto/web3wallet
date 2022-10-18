// Created by web3d4v on 06/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultCurrencyPickerWireframe {
    
    private weak var parent: UIViewController?
    private let context: CurrencyPickerWireframeContext
    private let currencyAddWireframeFactory: CurrencyAddWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencyPickerWireframeContext,
        currencyAddWireframeFactory: CurrencyAddWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.currencyAddWireframeFactory = currencyAddWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultCurrencyPickerWireframe: CurrencyPickerWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(destination___ destination: CurrencyPickerWireframeDestination) {
        if let target = destination as? CurrencyPickerWireframeDestination.AddCustomCurrency {
            currencyAddWireframeFactory.make(
                vc,
                context: .init(network: target.network)
            ).present()
        }
        if (destination as? CurrencyPickerWireframeDestination.Dismiss) != nil {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultCurrencyPickerWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencyPickerInteractor(
            walletService: walletService,
            currencyStoreService: currencyStoreService
        )
        let vc: CurrencyPickerViewController = UIStoryboard(.currencyPicker).instantiate()
        let presenter = DefaultCurrencyPickerPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        vc.context = context
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
}
