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
    case confirmSwap(context: ConfirmationWireframeContext.Swap)
    case confirmApproval(
        currency: Currency,
        onApproved: (_ password: String, _ salt: String) -> Void,
        networkFee: NetworkFee
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
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencySwapWireframeContext,
        currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        swapService: UniswapService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.currencyPickerWireframeFactory = currencyPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.swapService = swapService
        self.currencyStoreService = currencyStoreService
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
        case let .confirmSwap(context):
            confirmationWireframeFactory.make(vc, context: context).present()
        case let .confirmApproval(currency, onApproved, networkFee):
            let context = ConfirmationWireframeContext.ApproveUniswap(
                data: .init(currency: currency, onApproved: onApproved, networkFee: networkFee)
            )
            confirmationWireframeFactory.make(vc, context: context).present()
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
            swapService: swapService,
            currencyStoreService: currencyStoreService
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
        guard parent?.asNavVc == nil else { return vc }
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
                isMultiSelect: false,
                showAddCustomCurrency: false,
                networksData: [.init(network: network, favouriteCurrencies: nil, currencies: nil)],
                selectedNetwork: nil,
                handler: onCompletionDismissWrapped(with: onCompletion)
            )
        ).present()
    }
    
    func onCompletionDismissWrapped(
        with onCompletion: @escaping (Currency) -> Void
    ) -> (([CurrencyPickerWireframeContext.Result]) -> Void) {
        {
            [weak self] result in
            guard let self = self else { return }
            if let currency = result.first?.selectedCurrencies.first {
                onCompletion(currency)
            }
            self.vc?.presentedViewController?.dismiss(animated: true)
        }
    }
}
