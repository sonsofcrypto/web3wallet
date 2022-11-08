// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore
import UniformTypeIdentifiers

enum MnemonicUpdatePresenterEvent {
    case didTapMnemonic
    case didChangeName(name: String)
    case didChangeICouldBackup(onOff: Bool)
    case didChangeAddAccount(toCustom: Bool)
    case didChangeAccount(idx: Int)
    case didChangeCustomDerivation(path: String)
    case didTapAddAccount
    case didSelectCta
    case didSelectDismiss
    case deleteWallet
}

protocol MnemonicUpdatePresenter {
    func present()
    func handle(_ event: MnemonicUpdatePresenterEvent)
}

final class DefaultMnemonicUpdatePresenter {
    private weak var view: MnemonicUpdateView?
    private let wireframe: MnemonicUpdateWireframe
    private let interactor: MnemonicUpdateInteractor
    private let context: MnemonicUpdateContext

    private var password: String = ""
    private var salt: String = ""
    private var customDerivation: Bool = false

    init(
        view: MnemonicUpdateView,
        wireframe: MnemonicUpdateWireframe,
        interactor: MnemonicUpdateInteractor,
        context: MnemonicUpdateContext
    ) {
        self.view = view
        self.wireframe = wireframe
        self.interactor = interactor
        self.context = context
    }

    private func updateView() {
        view?.update(with: viewModel())
    }
}

extension DefaultMnemonicUpdatePresenter: MnemonicUpdatePresenter {

    func present() {
        updateView()
        wireframe.navigate(
            to: .authenticate(
                context: .init(
                    title: Localized("authenticate.title.unlock"),
                    keyStoreItem: context.keyStoreItem,
                    handler: onAuthenticatedHandler()
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
        case .didChangeAddAccount:
            () // TODO: When implementing accounts
        case .didChangeAccount:
            () // TODO: When implementing accounts
        case .didChangeCustomDerivation:
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
        case .deleteWallet:
            wireframe.navigate(
                to: .confirmationAlert(onConfirm: { [weak self] in self?.onDeleteConfirmed() })
            )
        }
    }
}

// MARK: - Action handlers

private extension DefaultMnemonicUpdatePresenter {
    
    @objc func onDeleteConfirmed() {
        interactor.delete(context.keyStoreItem)
        context.onKeyStoreItemDeleted?()
        // NOTE: The following call dismisses the alert
        view?.dismiss(
            animated: true,
            completion: { [weak self] in
                guard let self = self else { return }
                self.view?.dismiss(animated: true, completion: {})
            }
        )
    }
    
    func onAuthenticatedHandler() -> (AuthenticateData?, KotlinError?) -> Void {
        {
            [weak self] data, error in
            if let data = data {
                self?.onAuthenticateSuccess(data: data)
            } else {
                self?.onAuthenticateError()
            }
        }
    }
    
    func onAuthenticateSuccess(data: AuthenticateData) {
        self.password = data.password
        self.salt = data.salt
        do {
            try interactor.setup(
                for: context.keyStoreItem,
                password: password,
                salt: salt
            )
            updateView()
        } catch {
            onAuthenticateError()
        }
    }
    
    func onAuthenticateError() {
        wireframe.navigate(to: .dismiss)
    }
}

// MARK: - MnemonicUpdateViewModel utilities

private extension DefaultMnemonicUpdatePresenter {

    func viewModel() -> MnemonicUpdateViewModel {
        .init(
            sectionsItems: [
                mnemonicSectionItems(),
                optionsSectionItems(),
                deleteItems()
            ],
            headers: [.none, .none, .none],
            footers: [
                .attrStr(
                    text: Localized("mnemonicNew.footer"),
                    highlightWords: Constant.mnemonicHighlightWords
                ),
                .none,
                .none
            ],
            cta: Localized("mnemonicNew.cta.update")
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
                    title: Localized("mnemonicNew.name.title"),
                    value: interactor.name,
                    placeholder: Localized("mnemonicNew.name.placeholder")
                )
            ),
            MnemonicUpdateViewModel.Item.switch(
                title: Localized("mnemonicNew.iCould.title"),
                onOff: interactor.iCloudSecretStorage
            )
        ]
    }
    
    func deleteItems() -> [MnemonicUpdateViewModel.Item] {
        [
            MnemonicUpdateViewModel.Item.delete(
                title: Localized("mnemonicNew.cta.delete")
            )
        ]
    }
}

// MARK: - Constant

private extension DefaultMnemonicUpdatePresenter {

    enum Constant {
        static let mnemonicHighlightWords: [String] = [
            Localized("mnemonicNew.footerHighlightWord0"),
            Localized("mnemonicNew.footerHighlightWord1"),
        ]
    }
}
