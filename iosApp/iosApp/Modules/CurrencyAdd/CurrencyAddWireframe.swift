// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

// MARK: - CurrencyAddWireframeContext

struct CurrencyAddWireframeContext {
    let network: Network
}

// MARK: - CurrencyAddWireframeDestination

enum CurrencyAddWireframeDestination {
    case selectNetwork(onCompletion: (Network) -> Void)
    case qrCodeScan(network: Network, onCompletion: (String) -> Void)
}

// MARK: - CurrencyAddWireframe

protocol CurrencyAddWireframe {
    func present()
    func navigate(to destination: CurrencyAddWireframeDestination)
    func dismiss()
}

// MARK: - DefaultTokenAddWireframe

final class DefaultCurrencyAddWireframe {
    private weak var parent: UIViewController?
    private let context: CurrencyAddWireframeContext
    private let networkPickerWireframeFactory: NetworkPickerWireframeFactory
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencyAddWireframeContext,
        networkPickerWireframeFactory: NetworkPickerWireframeFactory,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.networkPickerWireframeFactory = networkPickerWireframeFactory
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultCurrencyAddWireframe: CurrencyAddWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: CurrencyAddWireframeDestination) {
        switch destination {
        case let .selectNetwork(onCompletion):
            networkPickerWireframeFactory.make(
                vc?.navigationController,
                context: .init(onNetworkSelected: onCompletion)
            ).present()
        case let .qrCodeScan(network, onCompletion):
            qrCodeScanWireframeFactory.make(
                vc?.navigationController,
                context: .init(type: .network(network), onCompletion: onCompletion)
            ).present()
        }
    }
    
    func dismiss() {
        vc?.popOrDismiss()
    }
}

private extension DefaultCurrencyAddWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultTokenAddInteractor(
            currencyStoreService: currencyStoreService
        )
        let vc: CurrencyAddViewController = UIStoryboard(.currencyAdd).instantiate()
        let presenter = DefaultCurrencyAddPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        vc.hidesBottomBarWhenPushed = true
        self.vc = vc
        return vc
    }
}
