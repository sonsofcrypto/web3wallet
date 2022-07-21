// Created by web3d4v on 20/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol ConfirmationWireframeFactory {

    func makeWireframe(
        presentingIn: UIViewController,
        context: ConfirmationWireframeContext
    ) -> ConfirmationWireframe
}

final class DefaultConfirmationWireframeFactory {

    private let authenticateWireframeFactory: AuthenticateWireframeFactory

    init(
        authenticateWireframeFactory: AuthenticateWireframeFactory
    ) {
        self.authenticateWireframeFactory = authenticateWireframeFactory
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
            authenticateWireframeFactory: authenticateWireframeFactory
        )
    }
}
