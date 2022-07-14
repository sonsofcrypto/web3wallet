// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib
import UniformTypeIdentifiers

enum MnemonicImportPresenterEvent {
    case didChangeMnemonic(mnemonic: String)
    case didChangeName(name: String)
    case didChangeICouldBackup(onOff: Bool)
    case saltSwitchDidChange(onOff: Bool)
    case didChangeSalt(salt: String)
    case saltLearnMoreAction
    case passTypeDidChange(idx: Int)
    case passwordDidChange(text: String)
    case allowFaceIdDidChange(onOff: Bool)
    case didTapMnemonic
    case didSelectCta
    case didSelectDismiss
}

protocol MnemonicImportPresenter {

    func present()
    func handle(_ event: MnemonicImportPresenterEvent)
}

// MARK: - DefaultMnemonicPresenter

final class DefaultMnemonicImportPresenter {

    private let context: MnemonicImportContext
    private let interactor: MnemonicImportInteractor
    private let wireframe: MnemonicImportWireframe

    private var password: String = ""
    private var salt: String = ""

    private weak var view: MnemonicImportView?

    init(
        context: MnemonicImportContext,
        view: MnemonicImportView,
        interactor: MnemonicImportInteractor,
        wireframe: MnemonicImportWireframe
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

extension DefaultMnemonicImportPresenter: MnemonicImportPresenter {

    func present() {
        let start = Date()
        updateView()
    }

    func handle(_ event: MnemonicImportPresenterEvent) {
        switch event {
        case let .didChangeMnemonic(text):
            interactor.mnemonic = text.split(separator: " ").map { String($0) }
            updateView()
        case let .didChangeName(name):
            interactor.name = name
        case let .didChangeICouldBackup(onOff):
            interactor.iCloudSecretStorage = onOff
        case let .saltSwitchDidChange(onOff):
            interactor.saltMnemonic = onOff
            updateView()
        case let .didChangeSalt(salt):
             self.salt = salt
        case .saltLearnMoreAction:
            wireframe.navigate(to: .learnMoreSalt)
        case let .passTypeDidChange(idx):
            let values =  KeyStoreItem.PasswordType.values()
            interactor.passwordType = values.get(index: Int32(idx))
                ?? interactor.passwordType
            updateView()
        case let .passwordDidChange(text):
            password = text
        case let .allowFaceIdDidChange(onOff):
            interactor.passUnlockWithBio = onOff
        case .didTapMnemonic:
            let mnemonicStr = interactor.mnemonic.joined(separator: " ")
            UIPasteboard.general.setItems(
                [[UTType.utf8PlainText.identifier: mnemonicStr]],
                options: [.expirationDate: Date().addingTimeInterval(30.0)]
            )
        case .didSelectCta:
            do {
                if interactor.passwordType == .bio {
                    password = interactor.generatePassword()
                } else {
                    // TODO(web3dgn): Validate password / pin handle error
                }
                let item = try interactor.createKeyStoreItem(password, salt: salt)
                if let handler = context.didCreteKeyStoreItemHandler {
                    handler(item)
                }
                // NOTE: Dispatching on next run loop so that presenting
                // controller collectionView has time to reload and does not
                // break custom dismiss animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.view?.dismiss(animated: true, completion: {})
                }
            } catch {
                // TODO: - Handle error
            }
        case .didSelectDismiss:
            view?.dismiss(animated: true, completion: {})
        }
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultMnemonicImportPresenter {

    func viewModel() -> MnemonicImportViewModel {
        if let error = interactor.mnemonicError(
            words: interactor.mnemonic,
            salt: salt
        ) {
            return .init(
                sectionsItems: [
                    mnemonicSectionItems()
                ],
                headers: [.none, .none],
                footers: [
                    .attrStr(
                        text: mnemonicErrorString(error) ?? Localized("newMnemonic.footer"),
                        highlightWords: Constant.mnemonicHighlightWords
                    ),
                    .none
                ],
                cta: Localized("newMnemonic.cta.import")
            )
        }

        return .init(
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

    func mnemonicSectionItems() -> [MnemonicImportViewModel.Item] {
        [
            MnemonicImportViewModel.Item.mnemonic(
                mnemonic: .init(
                    value: interactor.mnemonic.joined(separator: " "),
                    type: .new
                )
            )
        ]
    }

    func optionsSectionItems() -> [MnemonicImportViewModel.Item] {
        [
            MnemonicImportViewModel.Item.name(
                name: .init(
                    title: Localized("newMnemonic.name.title"),
                    value: interactor.name,
                    placeholder: Localized("newMnemonic.name.placeholder")
                )
            ),
            MnemonicImportViewModel.Item.switch(
                title: Localized("newMnemonic.iCould.title"),
                onOff: interactor.iCloudSecretStorage
            ),
            MnemonicImportViewModel.Item.switchWithTextInput(
                switchWithTextInput: .init(
                    title: Localized("newMnemonic.salt.title"),
                    onOff: interactor.saltMnemonic,
                    text: salt,
                    placeholder: Localized("newMnemonic.salt.placeholder"),
                    description: Localized("newMnemonic.salt.description"),
                    descriptionHighlightedWords: [
                        Localized("newMnemonic.salt.descriptionHighlight")
                    ]
                )
            ),
            MnemonicImportViewModel.Item.segmentWithTextAndSwitchInput(
                segmentWithTextAndSwitchInput: .init(
                    title: Localized("newMnemonic.passType.title"),
                    segmentOptions: passwordTypes().map { "\($0)".lowercased() },
                    selectedSegment: selectedPasswordTypeIdx(),
                    password: password,
                    placeholder: Localized("newMnemonic.passType.placeholder"),
                    onOffTitle: Localized("newMnemonic.passType.allowFaceId"),
                    onOff: interactor.passUnlockWithBio
                )
            )
        ]
    }

    func mnemonicErrorString(_ error: Error?) -> String? {
        print("===", error)
        guard let error = error else {
            return nil
        }

        if let err = error as? MnemonicImportInteractorError, err == .invalidWordCount,
            interactor.mnemonic.count > 12 {
            print("=== Invalid word count")
            return "Invalid word count" // TODO(web3dgn) localize 🙏
        }

        if let err = error as? Bip39.Error {
            print("=== bip39", err.message)
            return err.message
        }

        if let err = error as? KotlinError {
            print("=== KotlinError", err.message)
            return err.message
        }
        print("=== nil")
        return nil
    }
}

// MARK: - Utilities

private extension DefaultMnemonicImportPresenter {

    func selectedPasswordTypeIdx() -> Int {
        let values = KeyStoreItem.PasswordType.values()
        for idx in 0..<values.size {
            if values.get(index: idx) == interactor.passwordType {
                return Int(idx)
            }
        }
        return 2
    }

    func passwordTypes() -> [KeyStoreItem.PasswordType] {
        let values = KeyStoreItem.PasswordType.values()
        var array = [KeyStoreItem.PasswordType?]()
        for idx in 0..<values.size {
            array.append(values.get(index: idx))
        }
        return array.compactMap { $0 }
    }
}

// MARK: - Constant

private extension DefaultMnemonicImportPresenter {

    enum Constant {
        static let mnemonicHighlightWords: [String] = [
            Localized("newMnemonic.footerHighlightWord0"),
            Localized("newMnemonic.footerHighlightWord1"),
        ]
    }
}
