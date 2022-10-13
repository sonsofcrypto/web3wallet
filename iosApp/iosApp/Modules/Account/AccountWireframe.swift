// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

struct AccountWireframeContext {
    let network: Network
    let currency: Currency
}

enum AccountWireframeDestination {
    case receive
    case send
    case swap
    case more
}

protocol AccountWireframe {
    func present()
    func navigate(to destination: AccountWireframeDestination)
}

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
    private let transactionService: IosEtherscanService
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
        transactionService: IosEtherscanService,
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
        self.transactionService = transactionService
        self.settingsService = settingsService
    }
}

extension DefaultAccountWireframe: AccountWireframe {
    
    func present() {
        let vc = wireUp()
        self.vc = vc
        if settingsService.isSelected(item: .debugTransitions, action: .debugTransitionsCardFlip) {
            let presentingTopVc = (parent as? UINavigationController)?.topVc
            let presentedTopVc = (vc as? UINavigationController)?.topVc
            let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = delegate
            parent?.present(vc, animated: true)
        } else if settingsService.isSelected(item: .debugTransitions, action: .debugTransitionsSheet) {
            vc.modalPresentationStyle = .automatic
            parent?.show(vc, sender: self)
        }
    }

    func navigate(to destination: AccountWireframeDestination) {
        switch destination {
        case .receive:
            currencyReceiveWireframeFactory.make(
                vc,
                context: .init(network: context.network, currency: context.currency)
            ).present()
        case .send:
            currencySendWireframeFactory.make(
                vc,
                context: .init(
                    network: context.network,
                    address: nil,
                    currency: context.currency
                )
            ).present()
        case .swap:
            currencySwapWireframeFactory.make(
                vc,
                context: .init(
                    network: context.network,
                    currencyFrom: context.currency,
                    currencyTo: nil
                )
            ).present()
        case .more:
            deepLinkHandler.handle(deepLink: .degen)
        }
    }
}

private extension DefaultAccountWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultAccountInteractor(
            network: context.network,
            currency: context.currency,
            networksService: networksService,
            currencyStoreService: currencyStoreService,
            walletService: walletService,
            transactionService: transactionService
        )
        let vc: AccountViewController = UIStoryboard(.account).instantiate()
        let presenter = DefaultAccountPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.edgesForExtendedLayout = []
        vc.presenter = presenter
        return NavigationController(rootViewController: vc)
    }
}
