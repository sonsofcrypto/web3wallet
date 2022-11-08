// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultCurrencySendWireframe {
    private weak var parent: UIViewController?
    private let context: CurrencySendWireframeContext
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let currencyPickerWireframeFactory: CurrencyPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencySendWireframeContext,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.currencyPickerWireframeFactory = currencyPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultCurrencySendWireframe: CurrencySendWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(destination____ destination: CurrencySendWireframeDestination) {
        if destination is CurrencySendWireframeDestination.UnderConstructionAlert {
            let factory: AlertWireframeFactory = AppAssembler.resolve()
            factory.make(vc, context: .underConstructionAlert()).present()
        }
        if let input = destination as? CurrencySendWireframeDestination.QrCodeScan {
            let context = QRCodeScanWireframeContext(
                type: QRCodeScanWireframeContext.Type_Network(network: context.network),
                handler: onPopWrapped(onCompletion: input.onCompletion)
            )
            qrCodeScanWireframeFactory.make(vc, context: context).present()
        }
        if let input = destination as? CurrencySendWireframeDestination.SelectCurrency {
            let context = CurrencyPickerWireframeContext(
                isMultiSelect: false,
                showAddCustomCurrency: false,
                networksData: [.init(network: context.network, favouriteCurrencies: nil, currencies: nil)],
                selectedNetwork: nil,
                handler: onCompletionDismissWrapped(with: input.onCompletion)
            )
            currencyPickerWireframeFactory.make(vc, context: context).present()
        }
        if let input = destination as? CurrencySendWireframeDestination.ConfirmSend {
            guard input.context.data.addressFrom != input.context.data.addressTo else {
                return presentSendingToSameAddressAlert()
            }
            confirmationWireframeFactory.make(vc, context: input.context).present()
        }
        if destination is CurrencySendWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultCurrencySendWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencySendInteractor(
            walletService: walletService,
            networksService: networksService,
            currencyStoreService: currencyStoreService
        )
        let vc: CurrencySendViewController = UIStoryboard(.currencySend).instantiate()
        let presenter = DefaultCurrencySendPresenter(
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
    
    func presentSendingToSameAddressAlert() {
        alertWireframeFactory.make(
            vc,
            context: .init(
                title: Localized("alert.send.transaction.toYourself.title"),
                media: .image(named: "hand.raised", size: .init(length: 40)),
                message: Localized("alert.send.transaction.toYourself.message"),
                actions: [
                    .init(title: Localized("Ok"), type: .primary, action: nil)
                ],
                contentHeight: 230
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
    
    func onPopWrapped(onCompletion: @escaping (String) -> Void) -> (String) -> Void {
        {
            [weak self] string in
            _ = self?.vc?.navigationController?.popViewController(animated: true)
            onCompletion(string)
        }
    }
}
