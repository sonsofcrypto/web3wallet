// Created by web3d4v on 20/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

// MARK: TokenAddWireframeContext

struct TokenAddWireframeContext {
    let network: Network
}

// MARK: TokenAddWireframeDestination

enum TokenAddWireframeDestination {
    case selectNetwork(onCompletion: (Web3Network) -> Void)
    case qrCodeScan(network: Network, onCompletion: (String) -> Void)
}

// MARK: TokenAddWireframe

protocol TokenAddWireframe {
    func present()
    func navigate(to destination: TokenAddWireframeDestination)
    func dismiss()
}

// MARK: DefaultTokenAddWireframe

final class DefaultTokenAddWireframe {
    private weak var parent: UIViewController?
    private let context: TokenAddWireframeContext
    private let networkPickerWireframeFactory: NetworkPickerWireframeFactory
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: TokenAddWireframeContext,
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

extension DefaultTokenAddWireframe: TokenAddWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: TokenAddWireframeDestination) {
        switch destination {
        case let .selectNetwork(onCompletion):
            networkPickerWireframeFactory.makeWireframe(
                presentingIn: vc!.navigationController!,
                context: .init(presentationStyle: .push, onNetworkSelected: onCompletion)
            ).present()
        case let .qrCodeScan(network, onCompletion):
            qrCodeScanWireframeFactory.make(
                vc?.navigationController,
                context: .init(type: .network(network), onCompletion: onCompletion)
            ).present()
        }
    }
    
    func dismiss() {
        if let nc = vc?.navigationController as? NavigationController {
            nc.popViewController(animated: true)
        } else {
            vc?.dismiss(animated: true)
        }
    }
}

private extension DefaultTokenAddWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultTokenAddInteractor(
            currencyStoreService: currencyStoreService
        )
        let vc: TokenAddViewController = UIStoryboard(.tokenAdd).instantiate()
        let presenter = DefaultTokenAddPresenter(
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
