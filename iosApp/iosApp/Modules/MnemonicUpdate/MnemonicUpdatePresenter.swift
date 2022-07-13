// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib
import UniformTypeIdentifiers

enum MnemonicUpdatePresenterEvent {
    case didTapMnemonic
    case didChangeName(name: String)
    case didChangeICouldBackup(onOff: Bool)
    case didTapDelete
    case didChangeAddAccount(toCustom: Bool)
    case didChangeAccount(idx: Int)
    case didChangeCustomDerivation(path: String)
    case didTapAddAccount
    case didSelectCta
    case didSelectDismiss
}

protocol MnemonicUpdatePresenter {

    func present()
    func handle(_ event: MnemonicUpdatePresenterEvent)
}

// MARK: - DefaultMnemonicPresenter

final class DefaultMnemonicUpdatePresenter {

    private let context: MnemonicUpdateContext
    private let interactor: MnemonicUpdateInteractor
    private let wireframe: MnemonicUpdateWireframe

    private var password: String = ""
    private var salt: String = ""
    private var customDerivation: Bool = false

    private weak var view: MnemonicUpdateView?

    init(
        context: MnemonicUpdateContext,
        view: MnemonicUpdateView,
        interactor: MnemonicUpdateInteractor,
        wireframe: MnemonicUpdateWireframe
    ) {
        self.context = context
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }

    private func updateView() {
        view?.update(with: viewModel())
    }
}

// MARK: MnemonicPresenter

extension DefaultMnemonicUpdatePresenter: MnemonicUpdatePresenter {

    func present() {
        let start = Date()
        updateView()
        wireframe.navigate(
            to: .authenticate(
                context: .init(
                    title: "Unlock", // TODO(web3dgn): Title should for context dependent ie unlock, sign ...
                    keyStoreItem: context.keyStoreItem,
                    handler: handleAuthenticateResult
                )
            )
        )
    }

    func handle(_ event: MnemonicUpdatePresenterEvent) {
        switch event {
        case .didTapMnemonic:
            let mnemonicStr = interactor.mnemonic.joined(separator: " ")
            UIPasteboard.general.setItems(
                [[UTType.utf8PlainText.identifier: mnemonicStr]],
                options: [.expirationDate: Date().addingTimeInterval(30.0)]
            )
        case let .didChangeName(name):
            interactor.name = name
        case let .didChangeICouldBackup(onOff):
            interactor.iCloudSecretStorage = onOff
        case .didTapDelete:
            // TODO(web3dgn): Present are you sure as this will delete wallet
            interactor.delete(context.keyStoreItem)
        case let .didChangeAddAccount(toCustom):
            () // TODO: When implementing accounts
        case let .didChangeAccount(idx):
            () // TODO: When implementing accounts
        case let .didChangeCustomDerivation(path):
            () // TODO: When implementing accounts
        case .didTapAddAccount:
            () // TODO: When implementing accounts
        case .didSelectCta:
            do {
                let item = try interactor.update(for: context.keyStoreItem)
                if let handler = context.didUpdateKeyStoreItemHandler {
                    handler(item)
                }
                // NOTE: Dispatching on next run loop so that presenting
                // controller collectionView has time to reload and does not
                // break custom dismiss animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.view?.dismiss(animated: true, completion: {})
                }
            } catch {
                // TODO(web3dgn): - Handle error
            }
        case .didSelectDismiss:
            view?.dismiss(animated: true, completion: {})
        }
    }
}

// MARK: - Action handlers

private extension DefaultMnemonicUpdatePresenter {

    func handleAuthenticateResult(_ result: AuthenticateContext.AuthResult) {
        switch result {
        case let .success(password, salt):
            self.password = password
            self.salt = salt
            do {
                try interactor.setup(
                    for: context.keyStoreItem,
                    password: password,
                    salt: salt
                )
            } catch {
                // TODO(web3dgn): Present alert with ok, something along the
                // lines failed to unlock wallet. Tapping OK `wireframe.navigate(to: .dismiss)`
                // This is unrecoverable error but dont wanna crash the app for it
            }
        case let .failure(error):
            wireframe.navigate(to: .dismiss)
        }
    }
}

// MARK: - MnemonicUpdateViewModel utilities

private extension DefaultMnemonicUpdatePresenter {

    func viewModel() -> MnemonicUpdateViewModel {
        .init(
            sectionsItems: [
                mnemonicSectionItems(),
                optionsSectionItems()
            ],
            headers: [.none, .none],
            footers: [
                .attrStr(
                    text: Localized("newMnemonic.footer"),
                    highlightWords: Constant.mnemonicHighlightWords
                ),
                .none
            ],
            cta: Localized("newMnemonic.cta.new")
        )
    }

    func mnemonicSectionItems() -> [MnemonicUpdateViewModel.Item] {
        [
            MnemonicUpdateViewModel.Item.mnemonic(
                mnemonic: .init(
                    value: interactor.mnemonic.joined(separator: " "),
                    type: .hidden
                )
            )
        ]
    }

    func optionsSectionItems() -> [MnemonicUpdateViewModel.Item] {
        [
            MnemonicUpdateViewModel.Item.name(
                name: .init(
                    title: Localized("newMnemonic.name.title"),
                    value: interactor.name,
                    placeholder: Localized("newMnemonic.name.placeholder")
                )
            ),
            MnemonicUpdateViewModel.Item.switch(
                title: Localized("newMnemonic.iCould.title"),
                onOff: interactor.iCloudSecretStorage
            ),
        ]
    }
}

// MARK: - Constant

private extension DefaultMnemonicUpdatePresenter {

    enum Constant {
        static let mnemonicHighlightWords: [String] = [
            Localized("newMnemonic.footerHighlightWord0"),
            Localized("newMnemonic.footerHighlightWord1"),
        ]
    }
}
