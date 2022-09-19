// Created by web3d4v on 14/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct TokenSwapWireframeContext {
    let network: Network
    let currencyFrom: Currency?
    let currencyTo: Currency?
}

enum TokenSwapWireframeDestination {
    case underConstructionAlert
    case selectCurrencyFrom(onCompletion: (Currency) -> Void)
    case selectCurrencyTo(onCompletion: (Currency) -> Void)
    case confirmSwap(data: ConfirmationWireframeContext.SwapContext)
    case confirmApproval(
        currency: Currency,
        onApproved: ((password: String, salt: String)) -> Void
    )
}

protocol TokenSwapWireframe {
    func present()
    func navigate(to destination: TokenSwapWireframeDestination)
    func dismiss()
}

final class DefaultTokenSwapWireframe {
    private weak var parent: UIViewController?
    private let context: TokenSwapWireframeContext
    private let tokenPickerWireframeFactory: TokenPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let swapService: UniswapService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: TokenSwapWireframeContext,
        tokenPickerWireframeFactory: TokenPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        swapService: UniswapService
    ) {
        self.parent = parent
        self.context = context
        self.tokenPickerWireframeFactory = tokenPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.swapService = swapService
    }
}

extension DefaultTokenSwapWireframe: TokenSwapWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: TokenSwapWireframeDestination) {
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

private extension DefaultTokenSwapWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultTokenSwapInteractor(
            // NOTE: Passing network here is an edge case because is needed to configure swapService.
            // we can't do it here (wireframe) because this will live in a platform specific module and
            // DefaultCurrencySwapInteractor will be shared
            network: context.network,
            walletService: walletService,
            networksService: networksService,
            swapService: swapService
        )
        let vc: TokenSwapViewController = UIStoryboard(.tokenSwap).instantiate()
        let presenter = DefaultTokenSwapPresenter(
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
        tokenPickerWireframeFactory.make(
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
