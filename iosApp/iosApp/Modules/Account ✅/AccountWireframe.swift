// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct AccountWireframeContext {
    let network: Network
    let currency: Currency
}

enum AccountWireframeDestination {
    case receive
    case send
    case swap
    case more
}

protocol AccountWireframe {
    func present()
    func navigate(to destination: AccountWireframeDestination)
}

final class DefaultAccountWireframe {
    private weak var parent: UIViewController?
    private let context: AccountWireframeContext
    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let tokenSendWireframeFactory: TokenSendWireframeFactory
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let networksService: NetworksService
    private let currencyStoreService: CurrencyStoreService
    private let walletService: WalletService
    private let transactionService: EtherscanService
    
    private weak var vc: UIViewController?
    
    init(
        _ parent: UIViewController?,
        context: AccountWireframeContext,
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        networksService: NetworksService,
        currencyStoreService: CurrencyStoreService,
        walletService: WalletService,
        transactionService: EtherscanService
    ) {
        self.parent = parent
        self.context = context
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.networksService = networksService
        self.currencyStoreService = currencyStoreService
        self.walletService = walletService
        self.transactionService = transactionService
    }
}

extension DefaultAccountWireframe: AccountWireframe {
    
    func present() {
        let vc = wireUp()
        let presentingTopVc = (parent as? UINavigationController)?.topVc
        let presentedTopVc = (vc as? UINavigationController)?.topVc
        let delegate = presentedTopVc as? UIViewControllerTransitioningDelegate
        self.vc = vc
        vc.modalPresentationStyle = .overCurrentContext
        vc.transitioningDelegate = delegate
        presentingTopVc?.present(vc, animated: true)
    }

    func navigate(to destination: AccountWireframeDestination) {
        switch destination {
        case .receive:
            tokenReceiveWireframeFactory.make(
                vc,
                context: .init(network: context.network, currency: context.currency)
            ).present()
        case .send:
            tokenSendWireframeFactory.makeWireframe(
                presentingIn: vc!,
                context: .init(presentationStyle: .present, web3Token: web3Token(context))
            ).present()
        case .swap:
            tokenSwapWireframeFactory.makeWireframe(
                presentingIn: vc,
                context: .init(
                    presentationStyle: .present,
                    tokenFrom: web3Token(context),
                    tokenTo: nil
                )
            ).present()
        case .more:
            deepLinkHandler.handle(deepLink: .degen)
        }
    }

    func web3Token(_ context: AccountWireframeContext) -> Web3Token {
        Web3Token.from(
            currency: context.currency,
            network: Web3Network.from(
                context.network,
                isOn: true
            ),
            inWallet: true,
            idx: 0
        )
    }
}

private extension DefaultAccountWireframe {

    func wireUp() -> UIViewController {
        let interactor = DefaultAccountInteractor(
            network: context.network,
            currency: context.currency,
            networksService: networksService,
            currencyStoreService: currencyStoreService,
            walletService: walletService,
            transactionService: transactionService
        )
        let vc: AccountViewController = UIStoryboard(.account).instantiate()
        let presenter = DefaultAccountPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )
        vc.presenter = presenter
        vc.hidesBottomBarWhenPushed = true
        return NavigationController(rootViewController: vc)
    }
}
