// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NewMnemonicPresenterEvent {
    case didChangeName(name: String)
    case didChangeICouldBackup(onOff: Bool)
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
                            placeHolder: Localized("newMnemonic.name.placeholder")
                        )
                    ),
                    NewMnemonicViewModel.Item.onOffSwitch(
                        title: Localized("newMnemonic.iCould.title"),
                        onOff: keyStoreItem.iCouldBackup
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
