// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct CurrencySendWireframeContext {
    let network: Network
    let address: String?
    let currency: Currency?
}

enum CurrencySendWireframeDestination {
    case underConstructionAlert
    case qrCodeScan(network: Network, onCompletion: (String) -> Void)
    case selectCurrency(onCompletion: (Currency) -> Void)
    case confirmSend(context: ConfirmationWireframeContext.SendContext)
}

protocol CurrencySendWireframe {
    func present()
    func navigate(to destination: CurrencySendWireframeDestination)
    func dismiss()
}

final class DefaultCurrencySendWireframe {
    private weak var parent: UIViewController?
    private let context: CurrencySendWireframeContext
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let currencyPickerWireframeFactory: CurrencyPickerWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let walletService: WalletService
    private let networksService: NetworksService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: CurrencySendWireframeContext,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        currencyPickerWireframeFactory: CurrencyPickerWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        walletService: WalletService,
        networksService: NetworksService        
    ) {
        self.parent = parent
        self.context = context
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.currencyPickerWireframeFactory = currencyPickerWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.walletService = walletService
        self.networksService = networksService
    }
}

extension DefaultCurrencySendWireframe: CurrencySendWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: CurrencySendWireframeDestination) {
        switch destination {
        case .underConstructionAlert:
            let factory: AlertWireframeFactory = AppAssembler.resolve()
            factory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        case let .qrCodeScan(network, onCompletion):
            qrCodeScanWireframeFactory.make(
                vc,
                context: .init(type: .network(network), onCompletion: onCompletion)
            ).present()
        case let .selectCurrency(onCompletion):
            currencyPickerWireframeFactory.make(
                vc,
                context: .init(
                    title: .select,
                    selectedNetwork: context.network,
                    networks: .all,
                    source: .select(onCompletion: onCompletionDismissWrapped(with: onCompletion)),
                    showAddCustomCurrency: false
                )
            ).present()
        case let .confirmSend(dataIn):
            guard dataIn.addressFrom != dataIn.addressTo else {
                return presentSendingToSameAddressAlert()
            }
            confirmationWireframeFactory.make(
                vc,
                context: .init(type: .send(dataIn))
            ).present()
        }
    }
    
    func dismiss() { vc?.popOrDismiss() }
}

private extension DefaultCurrencySendWireframe {
    
    func onCompletionDismissWrapped(
        with onCompletion: @escaping (Currency) -> Void
    ) -> (Network, Currency) -> Void {
        {
            [weak self] (_, currency) in
            guard let self = self else { return }
            onCompletion(currency)
            self.vc?.presentedViewController?.dismiss(animated: true)
        }
    }
    
    func wireUp() -> UIViewController {
        let interactor = DefaultCurrencySendInteractor(
            walletService: walletService,
            networksService: networksService
        )
        let vc: CurrencySendViewController = UIStoryboard(.currencySend).instantiate()
        let presenter = DefaultCurrencySendPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
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
}
