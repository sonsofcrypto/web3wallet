// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

enum NewMnemonicPresenterEvent {

}

protocol NewMnemonicPresenter {

    func present()
    func handle(_ event: NewMnemonicPresenterEvent)
}

// MARK: - DefaultNewMnemonicPresenter

class DefaultNewMnemonicPresenter {

    private let interactor: NewMnemonicInteractor
    private let wireframe: NewMnemonicWireframe

    // private var items: [Item]

    private weak var view: NewMnemonicView?

    init(
        view: NewMnemonicView,
        interactor: NewMnemonicInteractor,
        wireframe: NewMnemonicWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        // self.items = []
    }
}

// MARK: NewMnemonicPresenter

extension DefaultNewMnemonicPresenter: NewMnemonicPresenter {

    func present() {
        view?.update(with: viewModel(from: KeyStoreItem.rand()))
        // TODO: Interactor
    }

    func handle(_ event: NewMnemonicPresenterEvent) {

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
                ]
            ],
            headers: [.none],
            footers: [
                .attrStr(
                    text: Localized("newMnemonic.footer"),
                    highlightWords: Constant.mnemonicHighlightWords
                )
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
