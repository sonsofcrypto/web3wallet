// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

struct AccountWireframeContext {
    let wallet: Wallet
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
    private weak var presentingIn: UIViewController?
    private let context: AccountWireframeContext
    private let tokenReceiveWireframeFactory: TokenReceiveWireframeFactory
    private let tokenSendWireframeFactory: TokenSendWireframeFactory
    private let tokenSwapWireframeFactory: TokenSwapWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let walletConnectionService: WalletsConnectionService
    private let walletsStateService: WalletsStateService
    private let currenciesService: CurrenciesService
    private let currencyMetadataService: CurrencyMetadataService

    private weak var navigationController: NavigationController!

    init(
        presentingIn: UIViewController,
        context: AccountWireframeContext,
        tokenReceiveWireframeFactory: TokenReceiveWireframeFactory,
        tokenSendWireframeFactory: TokenSendWireframeFactory,
        tokenSwapWireframeFactory: TokenSwapWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        walletConnectionService: WalletsConnectionService,
        walletsStateService: WalletsStateService,
        currenciesService: CurrenciesService,
        currencyMetadataService: CurrencyMetadataService
    ) {
        self.presentingIn = presentingIn
        self.context = context
        self.tokenReceiveWireframeFactory = tokenReceiveWireframeFactory
        self.tokenSendWireframeFactory = tokenSendWireframeFactory
        self.tokenSwapWireframeFactory = tokenSwapWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.walletConnectionService = walletConnectionService
        self.walletsStateService = walletsStateService
        self.currenciesService = currenciesService
        self.currencyMetadataService = currencyMetadataService
    }
}

extension DefaultAccountWireframe: AccountWireframe {

    func present() {
        let vc = wireUp()
        let topVc = (presentingIn as? UINavigationController)?.topViewController

        if let transitionDelegate =  topVc as? UIViewControllerTransitioningDelegate {
            vc.transitioningDelegate = transitionDelegate
        }

        vc.modalPresentationStyle = .overCurrentContext
        topVc?.show(vc, sender: self)
    }

    func navigate(to destination: AccountWireframeDestination) {

        switch destination {
        case .receive:
            let wireframe = tokenReceiveWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(presentationStyle: .present, web3Token: web3Token(context))
            )
            wireframe.present()
            
        case .send:
            tokenSendWireframeFactory.makeWireframe(
                presentingIn: navigationController,
                context: .init(presentationStyle: .present, web3Token: web3Token(context))
            ).present()
            
        case .swap:
            tokenSwapWireframeFactory.makeWireframe(
                presentingIn: navigationController,
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
                context.wallet.network() ?? Network.ethereum(),
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
            wallet: context.wallet,
            currency: context.currency,
            walletConnectionService: walletConnectionService,
            walletsStateService: walletsStateService,
            currenciesService: currenciesService,
            currencyMetadataService: currencyMetadataService
        )
        
        let vc: AccountViewController = UIStoryboard(.account).instantiate()
        let presenter = DefaultAccountPresenter(
            view: vc,
            interactor: interactor,
            wireframe: self,
            context: context
        )

        vc.presenter = presenter
        let navigationController = NavigationController(rootViewController: vc)
        self.navigationController = navigationController
        return navigationController
    }
}
