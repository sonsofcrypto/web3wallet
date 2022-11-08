// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultNFTSendWireframe {
    private weak var parent: UIViewController?
    private let context: NFTSendWireframeContext
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: NFTSendWireframeContext,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultNFTSendWireframe: NFTSendWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(destination_________ destination: NFTSendWireframeDestination) {
        if destination is NFTSendWireframeDestination.UnderConstructionAlert {
            alertWireframeFactory.make(vc, context: .underConstructionAlert()).present()
        }
        if let input = destination as? NFTSendWireframeDestination.QRCodeScan {
            let context = QRCodeScanWireframeContext(
                type: QRCodeScanWireframeContext.Type_Network(network: context.network),
                handler: onPopWrapped(onCompletion: input.onCompletion)
            )
            qrCodeScanWireframeFactory.make(vc, context: context).present()
        }
        if let input = destination as? NFTSendWireframeDestination.ConfirmSendNFT {
            guard input.context.data.addressFrom != input.context.data.addressTo else {
                return presentSendingToSameAddressAlert()
            }
            confirmationWireframeFactory.make(vc, context: input.context).present()
        }
        if destination is NFTSendWireframeDestination.Dismiss {
            vc?.popOrDismiss()
        }
    }
}

private extension DefaultNFTSendWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultNFTSendInteractor(
            networksService: networksService,
            currencyStoreService: currencyStoreService
        )
        let vc: NFTSendViewController = UIStoryboard(.nftSend).instantiate()
        let presenter = DefaultNFTSendPresenter(
            view: WeakRef(referred: vc),
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.hidesBottomBarWhenPushed = true
        vc.presenter = presenter
        self.vc = vc
        return vc
    }
    
    func presentSendingToSameAddressAlert() {
        let context = AlertWireframeContext(
            title: Localized("alert.send.transaction.toYourself.title"),
            media: AlertWireframeContext.MediaImage(
                named: "hand.raised",
                width: 40.uint32,
                height: 40.uint32
            ),
            message: Localized("alert.send.transaction.toYourself.message"),
            actions: [
                AlertWireframeContext.Action(title: Localized("Ok"), type: .primary)
            ],
            onActionTapped: nil,
            contentHeight: 230
        )
        alertWireframeFactory.make(vc, context: context).present()
    }
    
    func onPopWrapped(onCompletion: @escaping (String) -> Void) -> (String) -> Void {
        {
            [weak self] string in
            _ = self?.vc?.navigationController?.popViewController(animated: true)
            onCompletion(string)
        }
    }
}
