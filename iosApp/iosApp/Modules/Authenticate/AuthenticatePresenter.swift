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

final class DefaultAuthenticatePresenter {

    private weak var view: AuthenticateView?
    private let context: AuthenticateContext
    private let interactor: AuthenticateInteractor
    private let wireframe: AuthenticateWireframe

    private var password: String = ""
    private var salt: String = ""

    init(
        view: AuthenticateView,
        context: AuthenticateContext,
        interactor: AuthenticateInteractor,
        wireframe: AuthenticateWireframe
    ) {
        self.view = view
        self.context = context
        self.interactor = interactor
        self.wireframe = wireframe
    }

    func updateView() {
        view?.update(with: viewModel())
    }
}

extension DefaultAuthenticatePresenter: AuthenticatePresenter {

    func present() {
        
        updateView()
        
        guard keyStoreItem.passUnlockWithBio else { return }
        
        interactor.unlockWithBiometrics(
            keyStoreItem,
            title: Localized("authenticate.title.unlock"),
            handler: { [weak self] result in
                switch result {
                case let .success(password):
                    self?.password = password.0
                    self?.updateView()
                default:
                    ()
                }
            }
        )
        
    }

    func handle(_ event: AuthenticatePresenterEvent) {
        
        switch event {
        case let .didChangePassword(text):
            password = text
        case let .didChangeSalt(text):
            salt = text
        case .didCancel:
            wireframe.dismiss()
            context.handler(
                .failure(AuthenticatePresenterErrror.failedToAuthenticate)
            )
        case .didConfirm:
            guard interactor.isValid(
                item: keyStoreItem,
                password: password,
                salt: salt
            ) else {
                view?.animateError()
                return
            }
            wireframe.dismiss()
            context.handler(.success((password, salt)))
        }
    }
}

private extension DefaultAuthenticatePresenter {
    
    var keyStoreItem: KeyStoreItem {
        
        guard let keyStoreItem = context.keyStoreItem else {
            
            fatalError("This should never happen, the wireframe will guard against this")
        }
        
        return keyStoreItem
    }
    
    func viewModel() -> AuthenticateViewModel {

        .init(
            title: Localized("authenticate.title.unlock"),
            password: password,
            passwordPlaceholder: Localized("authenticate.placeholder.password"),
            salt: salt,
            saltPlaceholder: Localized("authenticate.placeholder.salt"),
            needsPassword: keyStoreItem.passwordType != .bio,
            needsSalt: keyStoreItem.saltMnemonic
        )
    }
}
