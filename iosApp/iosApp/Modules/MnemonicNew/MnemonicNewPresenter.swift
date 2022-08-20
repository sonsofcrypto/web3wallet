// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib
import UniformTypeIdentifiers

enum MnemonicNewPresenterEvent {
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

protocol MnemonicNewPresenter {

    func present()
    func handle(_ event: MnemonicNewPresenterEvent)
}

// MARK: - DefaultMnemonicPresenter

final class DefaultMnemonicNewPresenter {

    private let context: MnemonicNewContext
    private let interactor: MnemonicNewInteractor
    private let wireframe: MnemonicNewWireframe

    private var password: String = ""
    private var salt: String = ""
    private var ctaTapped = false

    private weak var view: MnemonicNewView?

    init(
        context: MnemonicNewContext,
        view: MnemonicNewView,
        interactor: MnemonicNewInteractor,
        wireframe: MnemonicNewWireframe
    ) {
        self.context = context
        self.view = view
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: MnemonicPresenter

extension DefaultMnemonicNewPresenter: MnemonicNewPresenter {

    func present() {
        interactor.generateNewMnemonic()
        updateView()
    }

    func handle(_ event: MnemonicNewPresenterEvent) {
        switch event {
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
            updateView()
        case let .allowFaceIdDidChange(onOff):
            interactor.passUnlockWithBio = onOff
        case .didTapMnemonic:
            let mnemonicStr = interactor.mnemonic.joined(separator: " ")
            UIPasteboard.general.setItems(
                [[UTType.utf8PlainText.identifier: mnemonicStr]],
                options: [.expirationDate: Date().addingTimeInterval(30.0)]
            )
        case .didSelectCta:
            ctaTapped = true
            guard isValidForm else { return updateView() }
            do {
                if interactor.passwordType == .bio {
                    password = interactor.generatePassword()
                } else {
                    // TODO(web3dgn): Validate password / pin
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
            } catch let error {
                // TODO: - Handle error
                print("[ERROR]: Error creating KeyStoreItem, with: \(error)")
            }
        case .didSelectDismiss:
            view?.dismiss(animated: true, completion: {})
        }
    }
}

// MARK: - WalletsViewModel utilities

private extension DefaultMnemonicNewPresenter {
    
    func updateView() {
        
        view?.update(with: viewModel())
    }
    
    var isValidForm: Bool {
        
        passwordErrorMessage == nil
    }
    
    var passwordErrorMessage: String? {
        
        guard ctaTapped else { return nil }
        
        switch interactor.passwordType {
            
        case .pin:
            let validator = PasswordValidatorHelper()
            return validator.validate(password, type: .pin)

        case .pass:
            let validator = PasswordValidatorHelper()
            return validator.validate(password, type: .pass)
            
        default:
            return nil
        }
    }

    func viewModel() -> MnemonicNewViewModel {
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

    func mnemonicSectionItems() -> [MnemonicNewViewModel.Item] {
        [
            MnemonicNewViewModel.Item.mnemonic(
                mnemonic: .init(
                    value: interactor.mnemonic.joined(separator: " "),
                    type: .new
                )
            )
        ]
    }

    func optionsSectionItems() -> [MnemonicNewViewModel.Item] {
        [
            MnemonicNewViewModel.Item.name(
                name: .init(
                    title: Localized("newMnemonic.name.title"),
                    value: interactor.name,
                    placeholder: Localized("newMnemonic.name.placeholder")
                )
            ),
            MnemonicNewViewModel.Item.switch(
                title: Localized("newMnemonic.iCould.title"),
                onOff: interactor.iCloudSecretStorage
            ),
            MnemonicNewViewModel.Item.switchWithTextInput(
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
            MnemonicNewViewModel.Item.segmentWithTextAndSwitchInput(
                viewModel: .init(
                    title: Localized("newMnemonic.passType.title"),
                    segmentOptions: passwordTypes().map { "\($0)".lowercased() },
                    selectedSegment: selectedPasswordTypeIdx(),
                    password: password,
                    passwordKeyboardType: interactor.passwordType == .pin
                    ? .numberPad
                    : .default,
                    placeholder: interactor.passwordType == .pin
                    ? Localized("newMnemonic.pinType.placeholder")
                    : Localized("newMnemonic.passType.placeholder"),
                    errorMessage: passwordErrorMessage,
                    onOffTitle: Localized("newMnemonic.passType.allowFaceId"),
                    onOff: interactor.passUnlockWithBio
                )
            )
        ]
    }
}

// MARK: - Utilities

private extension DefaultMnemonicNewPresenter {
    
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

private extension DefaultMnemonicNewPresenter {

    enum Constant {
        static let mnemonicHighlightWords: [String] = [
            Localized("newMnemonic.footerHighlightWord0"),
            Localized("newMnemonic.footerHighlightWord1"),
        ]
    }
}
