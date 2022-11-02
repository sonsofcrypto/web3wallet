// Created by web3d4v on 04/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

struct NFTSendWireframeContext {
    let network: Network
    let nftItem: NFTItem
}

enum NFTSendWireframeDestination {
    case underConstructionAlert
    case qrCodeScan(network: Network, onCompletion: (String) -> Void)
    case confirmSendNFT(context: ConfirmationWireframeContext.SendNFT)
}

protocol NFTSendWireframe {
    func present()
    func navigate(to destination: NFTSendWireframeDestination)
    func dismiss()
}

final class DefaultNFTSendWireframe {
    private weak var parent: UIViewController?
    private let context: NFTSendWireframeContext
    private let qrCodeScanWireframeFactory: QRCodeScanWireframeFactory
    private let confirmationWireframeFactory: ConfirmationWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let networksService: NetworksService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: NFTSendWireframeContext,
        qrCodeScanWireframeFactory: QRCodeScanWireframeFactory,
        confirmationWireframeFactory: ConfirmationWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        networksService: NetworksService
    ) {
        self.parent = parent
        self.context = context
        self.qrCodeScanWireframeFactory = qrCodeScanWireframeFactory
        self.confirmationWireframeFactory = confirmationWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.networksService = networksService
    }
}

extension DefaultNFTSendWireframe: NFTSendWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.show(vc, sender: self)
    }
    
    func navigate(to destination: NFTSendWireframeDestination) {
        switch destination {
        case .underConstructionAlert:
            alertWireframeFactory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        case let .qrCodeScan(network, onCompletion):
            let context = QRCodeScanWireframeContext(
                type: QRCodeScanWireframeContext.Type_Network(network: network),
                handler: onPopWrapped(onCompletion: onCompletion)
            )
            qrCodeScanWireframeFactory.make(vc, context: context).present()
        case let .confirmSendNFT(context):
            guard context.data.addressFrom != context.data.addressTo else {
                return presentSendingToSameAddressAlert()
            }
            confirmationWireframeFactory.make(vc, context: context).present()
        }
    }
    
    func dismiss() { vc?.popOrDismiss() }
}

private extension DefaultNFTSendWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultNFTSendInteractor(
            networksService: networksService
        )
        let vc: NFTSendViewController = UIStoryboard(.nftSend).instantiate()
        let presenter = DefaultNFTSendPresenter(
            view: vc,
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
    
    func onPopWrapped(onCompletion: @escaping (String) -> Void) -> (String) -> Void {
        {
            [weak self] string in
            _ = self?.vc?.navigationController?.popViewController(animated: true)
            onCompletion(string)
        }
    }
}
