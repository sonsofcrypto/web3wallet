// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum AuthenticatePresenterErrror: Error {
    case failedToAuthenticate
}

enum AuthenticatePresenterEvent {
    case didCancel
    case didConfirm
}

protocol AuthenticatePresenter {
    func present()
    func handle(_ event: AuthenticatePresenterEvent)
}

// MARK: - DefaultAuthenticatePresenter

class DefaultAuthenticatePresenter {

    private let context: AuthenticateContext
    private let interactor: AuthenticateInteractor
    private let wireframe: AuthenticateWireframe

    private weak var view: AuthenticateView?

    init(
        context: AuthenticateContext,
        view: AuthenticateView,
        interactor: AuthenticateInteractor,
        wireframe: AuthenticateWireframe
    ) {
        self.context = context
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: AuthenticatePresenter

extension DefaultAuthenticatePresenter: AuthenticatePresenter {

    func present() {
        view?.update(with: viewModel())
    }

    func handle(_ event: AuthenticatePresenterEvent) {
        switch event {
        case .didCancel:
            wireframe.dismiss()
            context.handler?(
                .failure(AuthenticatePresenterErrror.failedToAuthenticate)
            )
        case .didConfirm:
            ()
            // TODO: -
        }
    }
}

// MARK: - Event handling

private extension DefaultAuthenticatePresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultAuthenticatePresenter {

    func viewModel() -> AuthenticateViewModel {
        // TODO(Sancho): Update, fix, localize, make sane
        // Also view wise, I did no design just default elements
        .init(
            title: "Unlock",
            passwordPlaceholder: "Password",
            saltPlaceholder: "Sale"
        )
    }
}
