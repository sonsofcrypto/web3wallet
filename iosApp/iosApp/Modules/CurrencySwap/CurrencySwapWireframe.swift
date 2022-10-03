// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

struct CurrencySwapWireframeContext {
    let network: Network
    let currencyFrom: Currency?
    let currencyTo: Currency?
}

enum CurrencySwapWireframeDestination {
    case underConstructionAlert
    case selectCurrencyFrom(onCompletion: (Currency) -> Void)
    case selectCurrencyTo(onCompletion: (Currency) -> Void)
    case confirmSwap(data: ConfirmationWireframeContext.SwapContext)
    case confirmApproval(
        currency: Currency,
        onApproved: ((password: String, salt: String)) -> Void
    )
}

protocol CurrencySwapWireframe {
    func present()
    func navigate(to destination: CurrencySwapWireframeDestination)
    func dismiss()
}

final class DefaultCurrencySwapWireframe {
    private weak var parent: UIViewController?
    private let context: CurrencySwapWireframeContext
    private let currencyPickerWireframeFactory: CurrencyPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let swapService: UniswapService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencySwapWireframeContext,
        currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        swapService: UniswapService
    ) {
        self.parent = parent
        self.context = context
        self.currencyPickerWireframeFactory = currencyPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.swapService = swapService
    }
}

extension DefaultCurrencySwapWireframe: CurrencySwapWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: CurrencySwapWireframeDestination) {
        switch destination {
        case .underConstructionAlert:
            alertWireframeFactory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        case let .selectCurrencyFrom(onCompletion):
            presentCurrencyPicker(network: context.network, onCompletion: onCompletion)
        case let .selectCurrencyTo(onCompletion):
            presentCurrencyPicker(network: context.network, onCompletion: onCompletion)
        case let .confirmSwap(dataIn):
            confirmationWireframeFactory.make(
                vc,
                context: .init(type: .swap(dataIn))
            ).present()
        case let .confirmApproval(currency, onApproved):
            confirmationWireframeFactory.make(
                vc,
                context: .init(
                    type: .approveUniswap(
                        .init(
                            currency: currency,
                            onApproved: onApproved
                        )
                    )
                )
            ).present()
        }
    }
    
    func dismiss() { vc?.popOrDismiss() }
}

private extension DefaultCurrencySwapWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencySwapInteractor(
            // NOTE: Passing network here is an edge case because is needed to configure swapService.
            // we can't do it here (wireframe) because this will live in a platform specific module and
            // DefaultCurrencySwapInteractor will be shared
            network: context.network,
            walletService: walletService,
            networksService: networksService,
            swapService: swapService
        )
        let vc: CurrencySwapViewController = UIStoryboard(.currencySwap).instantiate()
        let presenter = DefaultCurrencySwapPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        vc.hidesBottomBarWhenPushed = true
        vc.presenter = presenter
        self.vc = vc
        guard parent?.asNavigationController == nil else { return vc }
        let nc = NavigationController(rootViewController: vc)
        self.vc = nc
        return nc
    }
    
    func presentCurrencyPicker(
        network: Network,
        onCompletion: @escaping (Currency) -> Void
    ) {
        currencyPickerWireframeFactory.make(
            vc,
            context: .init(
                title: .select,
                selectedNetwork: network,
                networks: .all,
                source: .select(
                    onCompletion: onCompletionDismissWrapped(with: onCompletion)
                ),
                showAddCustomCurrency: false
            )
        ).present()
    }
    
    func onCompletionDismissWrapped(
        with onCompletion: @escaping (Currency) -> Void
    ) -> (Network, Currency) -> Void {
        {
            [weak self] ( _, currency) in
            guard let self = self else { return }
            onCompletion(currency)
            self.vc?.presentedViewController?.dismiss(animated: true)
        }
    }
}
