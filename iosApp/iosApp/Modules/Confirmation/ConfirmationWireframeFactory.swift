// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3lib

protocol ConfirmationWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: ConfirmationWireframeContext
    ) -> ConfirmationWireframe
}

final class DefaultConfirmationWireframeFactory {

    private let walletService: WalletService
    private let authenticateWireframeFactory: AuthenticateWireframeFactory
    private let alertWireframeFactory: AlertWireframeFactory
    private let deepLinkHandler: DeepLinkHandler
    private let nftsService: NFTsService
    private let mailService: MailService

    init(
        walletService: WalletService,
        authenticateWireframeFactory: AuthenticateWireframeFactory,
        alertWireframeFactory: AlertWireframeFactory,
        deepLinkHandler: DeepLinkHandler,
        nftsService: NFTsService,
        mailService: MailService
    ) {
        self.walletService = walletService
        self.authenticateWireframeFactory = authenticateWireframeFactory
        self.alertWireframeFactory = alertWireframeFactory
        self.deepLinkHandler = deepLinkHandler
        self.nftsService = nftsService
        self.mailService = mailService
    }
}

extension DefaultConfirmationWireframeFactory: ConfirmationWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: ConfirmationWireframeContext
    ) -> ConfirmationWireframe {
        DefaultConfirmationWireframe(
            presentingIn: presentingIn,
            context: context,
            walletService: walletService,
            authenticateWireframeFactory: authenticateWireframeFactory,
            alertWireframeFactory: alertWireframeFactory,
            deepLinkHandler: deepLinkHandler,
            nftsService: nftsService,
            mailService: mailService
        )
    }
}

