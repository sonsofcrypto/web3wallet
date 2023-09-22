// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DefaultConfirmationWireframe {
    private weak var parent: UIViewController?
    private let context: ConfirmationWireframeContext
    private let walletService: WalletService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let webViewWireframeFactory: WebViewWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let nftsService: NFTsService
    private let mailService: MailService
    private let currencyStoreService: CurrencyStoreService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: ConfirmationWireframeContext,
        walletService: WalletService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        webViewWireframeFactory: WebViewWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        nftsService: NFTsService,
        mailService: MailService,
        currencyStoreService: CurrencyStoreService
    ) {
        self.parent = parent
        self.context = context
        self.walletService = walletService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.webViewWireframeFactory = webViewWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.nftsService = nftsService
        self.mailService = mailService
        self.currencyStoreService = currencyStoreService
    }
}

extension DefaultConfirmationWireframe {
    
    func present() {
        let vc = wireUp()
        parent?.present(vc, animated: true)
    }
    
    func navigate(with destination: ConfirmationWireframeDestination) {
        if let d = destination as? ConfirmationWireframeDestination.Authenticate {
            authenticateWireframeFactory.make(vc,context: d.context).present()
        }
        if destination is ConfirmationWireframeDestination.UnderConstruction {
            alertWireframeFactory.make(vc,context: .underConstructionAlert()).present()
        }
        if destination is ConfirmationWireframeDestination.Account {
            guard let context = context.accountWireframeContext else { return }
            let deepLink = DeepLink.account(context)
            deepLinkHandler.handle(deepLink: deepLink)
        }
        if destination is ConfirmationWireframeDestination.NftsDashboard {
            deepLinkHandler.handle(deepLink: .nftsDashboard)
        }
        if destination is ConfirmationWireframeDestination.CultProposals {
            deepLinkHandler.handle(deepLink: .cultProposals)
        }
        if let d = destination as? ConfirmationWireframeDestination.ViewEtherscan {
            guard let url = URL(string: "https://etherscan.io/tx/\(d.txHash)") else { return }
            webViewWireframeFactory.make(vc, context: .init(url: url)).present()
        }
        if let d = destination as? ConfirmationWireframeDestination.Report {
            let body = Localized("report.txFailed.error.body", d.error)
            mailService.sendMail(context: .init(subject: .beta, body: body))
        }
        if let d = destination as? ConfirmationWireframeDestination.Dismiss {
            vc?.dismiss(animated: true, completion: d.onCompletion)
        }
    }
}

private extension DefaultConfirmationWireframe {
    
    func wireUp() -> UIViewController {
        let interactor = DefaultConfirmationInteractor(
            walletService: walletService,
            nftsService: nftsService,
            currencyStoreService: currencyStoreService
        )
        let vc: ConfirmationViewController = UIStoryboard(.confirmation).instantiate()
        let presenter = DefaultConfirmationPresenter(
            view: WeakRef(referred: vc),
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

private extension ConfirmationWireframeContext {
    var accountWireframeContext: AccountWireframeContext? {
        if let c = self as? ConfirmationWireframeContext.Send {
            return .init(network: c.data.network, currency: c.data.currency)
        }
        if let c = self as? ConfirmationWireframeContext.Swap {
            return .init(network: c.data.network, currency: c.data.currencyFrom)
        }
        return nil
    }
}
