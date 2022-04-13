// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NewMnemonicPresenterEvent {
    case didChangeName(name: String)
    case didChangeICouldBackup(onOff: Bool)
    case saltSwitchDidChange(onOff: Bool)
    case didChangeSalt(salt: String)
    case saltLearnMoreAction
    case passTypeDidChange(idx: Int)
    case passwordDidChange(text: String)
    case allowFaceIdDidChange(onOff: Bool)
}

protocol NewMnemonicPresenter {

    func present()
    func handle(_ event: NewMnemonicPresenterEvent)
}

// MARK: - DefaultNewMnemonicPresenter

class DefaultNewMnemonicPresenter {

    private let interactor: NewMnemonicInteractor
    private let wireframe: NewMnemonicWireframe

    private lazy var keyStoreItem: KeyStoreItem = KeyStoreItem.rand()

    private weak var view: NewMnemonicView?

    init(
        view: NewMnemonicView,
        interactor: NewMnemonicInteractor,
        wireframe: NewMnemonicWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: NewMnemonicPresenter

extension DefaultNewMnemonicPresenter: NewMnemonicPresenter {

    func present() {
        view?.update(with: viewModel(from: keyStoreItem))
        // TODO: Interactor
    }

    func handle(_ event: NewMnemonicPresenterEvent) {
        switch event {
        case let .didChangeName(name):
            keyStoreItem.name = name
        case let .didChangeICouldBackup(onOff):
            keyStoreItem.iCouldBackup = onOff
        case let .saltSwitchDidChange(onOff):
            keyStoreItem.saltMnemonic = onOff
            view?.update(with: viewModel(from: keyStoreItem))
        case let .didChangeSalt(salt):
            keyStoreItem.mnemonicSalt = salt
        case .saltLearnMoreAction:
            wireframe.navigate(to: .learnMoreSalt)
        case let .passTypeDidChange(idx):
            if let passType = KeyStoreItem.PasswordType(rawValue: idx) {
                keyStoreItem.passwordType = passType
            }
            view?.update(with: viewModel(from: keyStoreItem))
        case let .passwordDidChange(text):
            keyStoreItem.password = text
        case let .allowFaceIdDidChange(onOff):
            keyStoreItem.allowPswdUnlockWithFaceId = onOff
        }
    }
}

// MARK: - Event handling

private extension DefaultNewMnemonicPresenter {

}

// MARK: - WalletsViewModel utilities

private extension DefaultNewMnemonicPresenter {

    func viewModel(from keyStoreItem: KeyStoreItem) -> NewMnemonicViewModel {
        .init(
            sectionsItems: [
                [
                    NewMnemonicViewModel.Item.mnemonic(
                        mnemonic: .init(value: keyStoreItem.mnemonic, type: .new)
                    )
                ],
                [
                    NewMnemonicViewModel.Item.name(
                        name: .init(
                            title: Localized("newMnemonic.name.title"),
                            value: keyStoreItem.name,
                            placeholder: Localized("newMnemonic.name.placeholder")
                        )
                    ),
                    NewMnemonicViewModel.Item.switch(
                        title: Localized("newMnemonic.iCould.title"),
                        onOff: keyStoreItem.iCouldBackup
                    ),
                    NewMnemonicViewModel.Item.switchWithTextInput(
                        switchWithTextInput: .init(
                            title: Localized("newMnemonic.salt.title"),
                            onOff: keyStoreItem.saltMnemonic,
                            text: keyStoreItem.mnemonicSalt,
                            placeholder: Localized("newMnemonic.salt.placeholder"),
                            description: Localized("newMnemonic.salt.description"),
                            descriptionHighlightedWords: [
                                Localized("newMnemonic.salt.descriptionHighlight")
                            ]
                        )
                    ),
                    NewMnemonicViewModel.Item.segmentWithTextAndSwitchInput(
                        segmentWithTextAndSwitchInput: .init(
                            title: Localized("newMnemonic.passType.title"),
                            segmentOptions: KeyStoreItem.PasswordType.allCases
                                    .map { $0.localizedDescription },
                            selectedSegment: keyStoreItem.passwordType.rawValue,
                            password: keyStoreItem.password,
                            placeholder: Localized("newMnemonic.passType.placeholder"),
                            onOffTitle: Localized("newMnemonic.passType.allowFaceId"),
                            onOff: keyStoreItem.allowPswdUnlockWithFaceId
                        )
                    )
                ]
            ],
            headers: [.none, .none],
            footers: [
                .attrStr(
                    text: Localized("newMnemonic.footer"),
                    highlightWords: Constant.mnemonicHighlightWords
                ),
                .none
            ]
        )
    }
}

// MARK: - Constant

private extension DefaultNewMnemonicPresenter {

    enum Constant {
        static let mnemonicHighlightWords: [String] = [
            Localized("newMnemonic.footerHighlightWord0"),
            Localized("newMnemonic.footerHighlightWord1"),
        ]
    }
}
