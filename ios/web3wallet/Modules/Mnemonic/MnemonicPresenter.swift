// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UniformTypeIdentifiers

enum MnemonicPresenterEvent {
    case didChangeName(name: String)
    case didChangeICouldBackup(onOff: Bool)
    case saltSwitchDidChange(onOff: Bool)
    case didChangeSalt(salt: String)
    case saltLearnMoreAction
    case passTypeDidChange(idx: Int)
    case passwordDidChange(text: String)
    case allowFaceIdDidChange(onOff: Bool)
    case didTapMnemonic
    case didChangeMnemonic(text: String)
    case didEndEditingMnemonic(text: String)
    case didSelectCta
    case didSelectDismiss
}

protocol MnemonicPresenter {

    func present()
    func handle(_ event: MnemonicPresenterEvent)
}

// MARK: - DefaultMnemonicPresenter

final class DefaultMnemonicPresenter {

    private let context: MnemonicContext
    private let interactor: MnemonicInteractor
    private let wireframe: MnemonicWireframe

    private var mnemonicHidden: Bool = true
    private var showMnemonicOnly: Bool = false

    private lazy var keyStoreItem: KeyStoreItem = KeyStoreItem.blank()

    private weak var view: MnemonicView?

    init(
        context: MnemonicContext,
        view: MnemonicView,
        interactor: MnemonicInteractor,
        wireframe: MnemonicWireframe
    ) {
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
        self.context = context
    }

    private func updateView() {
        view?.update(with: viewModel(from: keyStoreItem))
    }
}

// MARK: MnemonicPresenter

extension DefaultMnemonicPresenter: MnemonicPresenter {

    func present() {
        switch context.mode {
        case .new:
             keyStoreItem = interactor.generateNewKeyStoreItem()
        case let .update(item):
            keyStoreItem = item
        case .restore:
            keyStoreItem = KeyStoreItem.blank()
            showMnemonicOnly = true
        }
        updateView()
    }

    func handle(_ event: MnemonicPresenterEvent) {
        switch event {
        case let .didChangeName(name):
            keyStoreItem.name = name
        case let .didChangeICouldBackup(onOff):
            keyStoreItem.iCloudSecretStorage = onOff
        case let .saltSwitchDidChange(onOff):
            keyStoreItem.saltMnemonic = onOff
            updateView()
        case let .didChangeSalt(salt):
            keyStoreItem.mnemonicSalt = salt
        case .saltLearnMoreAction:
            wireframe.navigate(to: .learnMoreSalt)
        case let .passTypeDidChange(idx):
            if let passType = KeyStoreItem.PasswordType(rawValue: idx) {
                keyStoreItem.passwordType = passType
            }
            updateView()
        case let .passwordDidChange(text):
            keyStoreItem.password = text
        case let .allowFaceIdDidChange(onOff):
            keyStoreItem.passUnlockWithBio = onOff
        case .didTapMnemonic:
            if context.mode.isUpdate() && mnemonicHidden {
                mnemonicHidden = false
                updateView()
            }
            let pasteBoard = UIPasteboard.general.setItems(
                [[UTType.utf8PlainText.identifier: keyStoreItem.mnemonic]],
                options: [.expirationDate: Date().addingTimeInterval(30.0)])
        case let .didChangeMnemonic(text):
            keyStoreItem.mnemonic = text
            // TODO: - Validate and update view
        case let .didEndEditingMnemonic(text):
            // TODO: - Validate mnemonic
            showMnemonicOnly = false
            updateView()
        case .didSelectCta:
            interactor.update(keyStoreItem)
            switch context.mode {
            case .update:
                if let handler = context.didUpdateKeyStoreItemHandler {
                    handler(keyStoreItem)
                }
            default:
                if let handler = context.didCreteKeyStoreItemHandler {
                    handler(keyStoreItem)
                }
            }

            // NOTE: Dispatching on next run loop so that presenting controller
            // collectionView has time to reload and does not break custom
            // dismiss animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                self.view?.dismiss(animated: true, completion: {})
            }
        case let .didSelectDismiss:
            view?.dismiss(animated: true, completion: {})
        }
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultMnemonicPresenter {

    func viewModel(from keyStoreItem: KeyStoreItem) -> MnemonicViewModel {
        .init(
            sectionsItems: [
                mnemonicSectionItems(),
                showMnemonicOnly ? [] : optionsSectionItems()
            ],
            headers: [.none, .none],
            footers: [
                .attrStr(
                    text: Localized("newMnemonic.footer"),
                    highlightWords: Constant.mnemonicHighlightWords
                ),
                .none
            ],
            cta: {
                switch self.context.mode {
                case .new:
                    return Localized("newMnemonic.cta.new")
                case .update:
                    return Localized("newMnemonic.cta.update")
                case .restore:
                    return Localized("newMnemonic.cta.import")
                }
            }()
        )
    }

    func mnemonicSectionItems() -> [MnemonicViewModel.Item] {
        [
            MnemonicViewModel.Item.mnemonic(
                mnemonic: .init(
                    value: keyStoreItem.mnemonic,
                    type: {
                        switch self.context.mode {
                        case .new:
                            return .new
                        case .update:
                            return mnemonicHidden ? .editHidden : .editShown
                        case .restore:
                            return .importing
                        }
                    }()
                )
            )
        ]
    }

    func optionsSectionItems() -> [MnemonicViewModel.Item] {
        [
            MnemonicViewModel.Item.name(
                name: .init(
                    title: Localized("newMnemonic.name.title"),
                    value: keyStoreItem.name,
                    placeholder: Localized("newMnemonic.name.placeholder")
                )
            ),
            MnemonicViewModel.Item.switch(
                title: Localized("newMnemonic.iCould.title"),
                onOff: keyStoreItem.iCloudSecretStorage
            ),
            MnemonicViewModel.Item.switchWithTextInput(
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
            MnemonicViewModel.Item.segmentWithTextAndSwitchInput(
                segmentWithTextAndSwitchInput: .init(
                    title: Localized("newMnemonic.passType.title"),
                    segmentOptions: KeyStoreItem.PasswordType.allCases
                            .map { $0.localizedDescription },
                    selectedSegment: keyStoreItem.passwordType.rawValue,
                    password: keyStoreItem.password,
                    placeholder: Localized("newMnemonic.passType.placeholder"),
                    onOffTitle: Localized("newMnemonic.passType.allowFaceId"),
                    onOff: keyStoreItem.passUnlockWithBio
                )
            )
        ]
    }

}

// MARK: - Constant

private extension DefaultMnemonicPresenter {

    enum Constant {
        static let mnemonicHighlightWords: [String] = [
            Localized("newMnemonic.footerHighlightWord0"),
            Localized("newMnemonic.footerHighlightWord1"),
        ]
    }
}
