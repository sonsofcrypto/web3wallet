// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultAccountWireframe {
    private weak var parent: UIViewController?
    private let context: AccountWireframeContext
    private let currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory
    private let currencySendWireframeFactory: CurrencyCurrencyWireframeFactory
    private let currencySwapWireframeFactory: CurrencySwapWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let etherScanService: EtherScanService
    private let settingsService: SettingsService

    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: AccountWireframeContext,
        currencyReceiveWireframeFactory: CurrencyReceiveWireframeFactory,
        currencySendWireframeFactory: CurrencyCurrencyWireframeFactory,
        currencySwapWireframeFactory: CurrencySwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        etherScanService: EtherScanService,
        settingsService: SettingsService
    ) {
        self.parent = parent
        self.context = context
        self.currencyReceiveWireframeFactory = currencyReceiveWireframeFactory
        self.currencySendWireframeFactory = currencySendWireframeFactory
        self.currencySwapWireframeFactory = currencySwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.etherScanService = etherScanService
        self.settingsService = settingsService
    }
}

extension DefaultAccountWireframe {
    
    func present() {
        let vc = wireUp()
        self.vc = vc
        print("[DefaultAccountWireframe] Presenting")
        if settingsService.isSelected(
            setting: .init(group: .developer, action: .developerTransitionsSheet)
        ) {
            vc.modalPresentationStyle = .automatic
            parent?.show(vc, sender: self)
        } else {
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = delegate
            parent?.present(vc, animated: true)
        }
    }

    func navigate(with destination: AccountWireframeDestination) {
        if destination is AccountWireframeDestination.Receive {
            let context = CurrencyReceiveWireframeContext(network: context.network, currency: context.currency)
            currencyReceiveWireframeFactory.make(vc, context: context).present()
        }
        if destination is AccountWireframeDestination.Send {
            let context = CurrencySendWireframeContext(
                network: context.network,
                address: nil,
                currency: context.currency
            )
            currencySendWireframeFactory.make(vc, context: context).present()
        }
        if destination is AccountWireframeDestination.Swap {
            let context = CurrencySwapWireframeContext(
                network: context.network,
                currencyFrom: context.currency,
                currencyTo: nil
            )
            currencySwapWireframeFactory.make(vc, context: context).present()
        }
        if destination is AccountWireframeDestination.More {
            deepLinkHandler.handle(deepLink: .degen)
        }
    }
}

private extension DefaultAccountWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultAccountInteractor(
            currencyStoreService: currencyStoreService,
            walletService: walletService,
            etherScanService: etherScanService
        )
        let vc: AccountViewController = UIStoryboard(.account).instantiate()
        let presenter = DefaultAccountPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.edgesForExtendedLayout = []
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
