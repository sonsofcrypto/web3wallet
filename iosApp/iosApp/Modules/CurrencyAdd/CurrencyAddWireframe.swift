// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultCurrencyAddWireframe {
    private weak var parent: UIViewController?
    private let context: CurrencyAddWireframeContext
    private let networkPickerWireframeFactory: NetworkPickerWireframeFactory
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencyAddWireframeContext,
        networkPickerWireframeFactory: NetworkPickerWireframeFactory,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.networkPickerWireframeFactory = networkPickerWireframeFactory
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultCurrencyAddWireframe: CurrencyAddWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(destination_ destination: CurrencyAddWireframeDestination) {
        if let target = destination as? CurrencyAddWireframeDestination.NetworkPicker {
            networkPickerWireframeFactory.make(
                vc?.navigationController,
                context: .init(onNetworkSelected: target.handler)
            ).present()
        }
        if (destination as? CurrencyAddWireframeDestination.Dismiss) != nil {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultCurrencyAddWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencyAddInteractor(
            currencyStoreService: currencyStoreService
        )
        let vc: CurrencyAddViewController = UIStoryboard(.currencyAdd).instantiate()
        let presenter = DefaultCurrencyAddPresenter(
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
