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
    case didChangePassword(text: String)
    case didChangeSalt(text: String)
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

    private var password: String = ""
    private var salt: String = ""

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

    func updateView() {
        view?.update(with: viewModel())
    }
}

// MARK: AuthenticatePresenter

extension DefaultAuthenticatePresenter: AuthenticatePresenter {

    func present() {
        updateView()
        if context.keyStoreItem.passUnlockWithBio {
            interactor.unlockWithBiometrics(
                context.keyStoreItem,
                title: "Unlock", // TODO(web3dgn): Localized context aware title
                handler: { [weak self] result in
                    switch result {
                    case let .success(password, _):
                        self?.password = password
                        self?.updateView()
                    default:
                        ()
                    }
                }
            )
        }
    }

    func handle(_ event: AuthenticatePresenterEvent) {
        switch event {
        case let .didChangePassword(text):
            password = text
        case let .didChangeSalt(text):
            salt = text
        case .didCancel:
            wireframe.dismiss()
            context.handler?(
                .failure(AuthenticatePresenterErrror.failedToAuthenticate)
            )
        case .didConfirm:
            guard interactor.isValid(
                item: context.keyStoreItem,
                password: password,
                salt: salt
            ) else {
                view?.animateError()
                return
            }
            wireframe.dismiss()
            context.handler?(.success((password, salt)))
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
        let item = context.keyStoreItem
        return .init(
            title: "Unlock",
            password: password,
            passwordPlaceholder: "Password",
            salt: salt,
            saltPlaceholder: "Salt",
            needsPassword: item.passwordType != .bio,
            needsSalt: item.saltMnemonic
        )
    }
}
