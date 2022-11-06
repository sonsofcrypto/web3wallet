// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

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
    
    func navigate(destination_________ destination: CurrencySwapWireframeDestination) {
        if destination is CurrencySwapWireframeDestination.UnderConstructionAlert {
            alertWireframeFactory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        }
        if let input = destination as? CurrencySwapWireframeDestination.SelectCurrencyFrom {
            presentCurrencyPicker(network: context.network, onCompletion: input.onCompletion)
        }
        if let input = destination as? CurrencySwapWireframeDestination.SelectCurrencyTo {
            presentCurrencyPicker(network: context.network, onCompletion: input.onCompletion)
        }
        if let input = destination as? CurrencySwapWireframeDestination.ConfirmSwap {
            confirmationWireframeFactory.make(vc, context: input.context).present()
        }
        if let input = destination as? CurrencySwapWireframeDestination.ConfirmApproval {
            let context = ConfirmationWireframeContext.ApproveUniswap(
                data: .init(
                    currency: input.currency,
                    onApproved: input.onApproved,
                    networkFee: input.networkFee
                )
            )
            confirmationWireframeFactory.make(vc, context: context).present()
        }
        if destination is CurrencySwapWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultCurrencySwapWireframe {
    
    func wireUp() -> UIViewController {
        configureUniswapService()
        let interactor = DefaultCurrencySwapInteractor(
            walletService: walletService,
            networksService: networksService,
            swapService: swapService,
            currencyStoreService: currencyStoreService
        )
        let vc: CurrencySwapViewController = UIStoryboard(.currencySwap).instantiate()
        let presenter = DefaultCurrencySwapPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
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
    
    func configureUniswapService() {
        guard let wallet = networksService.wallet(network: context.network) else {
            fatalError("Unable to configure Uniswap service, no wallet found.")
        }
        let provider = networksService.provider(network: context.network)
        swapService.wallet = wallet
        swapService.provider = provider
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
