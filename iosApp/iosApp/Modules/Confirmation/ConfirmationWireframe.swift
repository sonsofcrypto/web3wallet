// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

enum ConfirmationWireframeDestination {
    case authenticate(AuthenticateContext)
    case underConstruction
    case account
    case nftsDashboard
    case cultProposals
    case viewEtherscan(txHash: String)
    case report(error: Error)
}

protocol ConfirmationWireframe {
    func present()
    func navigate(to destination: ConfirmationWireframeDestination)
    func dismiss()
}

final class DefaultConfirmationWireframe {
    private weak var parent: UIViewController?
    private let context: ConfirmationWireframeContext
    private let walletService: WalletService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let nftsService: NFTsService
    private let mailService: MailService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: ConfirmationWireframeContext,
        walletService: WalletService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        nftsService: NFTsService,
        mailService: MailService
    ) {
        self.parent = parent
        self.context = context
        self.walletService = walletService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.nftsService = nftsService
        self.mailService = mailService
    }
}

extension DefaultConfirmationWireframe: ConfirmationWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(to destination: ConfirmationWireframeDestination) {
        switch destination {
        case let .authenticate(context):
            authenticateWireframeFactory.make(
                vc,
                context: context
            ).present()
        case .underConstruction:
            alertWireframeFactory.make(
                vc,
                context: .underConstructionAlert()
            ).present()
        case .account:
            guard let token = context.token else { return }
            let deepLink = DeepLink.account(token: token)
            deepLinkHandler.handle(deepLink: deepLink)
        case .nftsDashboard:
            deepLinkHandler.handle(deepLink: .nftsDashboard)
        case .cultProposals:
            deepLinkHandler.handle(deepLink: .cultProposals)
        case let .viewEtherscan(txHash):
            EtherscanHelper().view(txHash: txHash, parent: vc)
        case let .report(error):
            let body = Localized(
                "report.txFailed.error.body",
                arg: error.localizedDescription
            )
            mailService.sendMail(context: .init(subject: .beta, body: body))
        }
    }
    
    func dismiss() {
        vc?.dismiss(animated: true)
    }
}

private extension DefaultConfirmationWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultConfirmationInteractor(
            walletService: walletService,
            nftsService: nftsService
        )
        let vc: ConfirmationViewController = UIStoryboard(.confirmation).instantiate()
        let presenter = DefaultConfirmationPresenter(
            view: vc,
            wireframe: self,
            interactor: interactor,
            context: context
        )
        vc.presenter = presenter
        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .custom
        nc.transitioningDelegate = vc
        self.vc = nc
        return nc
    }
}
