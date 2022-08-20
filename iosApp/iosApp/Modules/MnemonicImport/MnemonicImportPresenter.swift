// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib
import UniformTypeIdentifiers

enum MnemonicImportPresenterEvent {
    case mnemonicChanged(
        to: String,
        selectedLocation: Int
    )
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

final class DefaultMnemonicImportPresenter {

    private let context: MnemonicImportContext
    private weak var view: MnemonicImportView?
    private let interactor: MnemonicImportInteractor
    private let wireframe: MnemonicImportWireframe

    private var password: String = ""
    private var salt: String = ""
    private var ctaTapped = false
    
    private var mnemonic = ""
    private var selectedLocation = 0

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
}

extension DefaultMnemonicImportPresenter: MnemonicImportPresenter {

    func present() {

        updateView()
    }

    func handle(_ event: MnemonicImportPresenterEvent) {
        switch event {
        case let .mnemonicChanged(mnemonicIn, selectedLocationIn):
            let tuple = clearBlanksFromFrontOf(mnemonicIn, with: selectedLocationIn)
            
            self.mnemonic = tuple.mnemonic
            self.selectedLocation = tuple.selectedLocation
            
            interactor.mnemonic = mnemonic.trimmingCharacters(in: .whitespaces).split(
                separator: " "
            ).map { String($0) }
            
            updateView(updateMnemonic: mnemonicIn != mnemonic)

        case let .didChangeName(name):
            interactor.name = name
        case let .didChangeICouldBackup(onOff):
            interactor.iCloudSecretStorage = onOff
        case let .saltSwitchDidChange(onOff):
            interactor.saltMnemonic = onOff
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
            ctaTapped = true
            guard isValidForm else { return updateView() }
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

private extension DefaultMnemonicImportPresenter {
    
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
    
    func updateView(
        updateMnemonic: Bool = false
    ) {
        
        view?.update(
            with: viewModel(
                updateMnemonic: updateMnemonic
            )
        )
    }

    func viewModel(
        updateMnemonic: Bool
    ) -> MnemonicImportViewModel {
        
        if let error = interactor.mnemonicError(
            words: interactor.mnemonic,
            salt: salt
        ) {
            return .init(
                sectionsItems: [
                    mnemonicSectionItems(
                        updateMnemonic: updateMnemonic,
                        isValidMnemonic: false
                    )
                ],
                headers: [.none, .none],
                footers: mnemonicFootersError(error),
                cta: Localized("newMnemonic.cta.import")
            )
        }

        return .init(
            sectionsItems: [
                mnemonicSectionItems(
                    updateMnemonic: updateMnemonic,
                    isValidMnemonic: true
                ),
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
            cta: Localized("newMnemonic.cta.import")
        )
    }

    func mnemonicSectionItems(
        updateMnemonic: Bool,
        isValidMnemonic: Bool
    ) -> [MnemonicImportViewModel.Item] {
        [
            MnemonicImportViewModel.Item.mnemonic(
                mnemonic: makeMnemonic(updateMnemonic: updateMnemonic)
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

    func mnemonicFootersError(_ error: Error?) -> [
        MnemonicImportViewModel.Footer
    ] {
        
        guard let error = error else { return [.none] }
        
        switch error {
        case MnemonicImportInteractorError.invalidWordCount:
            
            return [
                .attrStr(
                    text: Localized("mnemonic.error.invalid.wordCount"),
                    highlightWords: [
                        Localized("mnemonic.error.invalid.wordCount.highlight0")
                    ]
                )
            ]
            
        default:
            
            return [
                .attrStr(
                    text: Localized("mnemonic.error.invalid"),
                    highlightWords: [
                        Localized("mnemonic.error.invalid")
                    ]
                )
            ]
        }
    }
}

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

private extension DefaultMnemonicImportPresenter {

    enum Constant {
        static let mnemonicHighlightWords: [String] = [
            Localized("newMnemonic.footerHighlightWord0"),
            Localized("newMnemonic.footerHighlightWord1"),
        ]
    }
}

private extension DefaultMnemonicImportPresenter {
    
    func clearBlanksFromFrontOf(
        _ mnemonic: String,
        with selectedLocation: Int
    ) -> (mnemonic: String, selectedLocation: Int) {
        
        let initialCount = mnemonic.count
        
        var mnemonic = mnemonic
        if let c = (mnemonic.first { !($0 == " " || $0 == "\t" || $0 == "\n") }) {
            if let nonWhiteSpaceIndex = mnemonic.firstIndex(of: c) {
                mnemonic.replaceSubrange(mnemonic.startIndex ..< nonWhiteSpaceIndex, with: "")
            }
        }
        
        let finalCount = mnemonic.count
        return (mnemonic, selectedLocation - (initialCount - finalCount))
    }
    
    func makeMnemonic(
        updateMnemonic: Bool
    ) -> MnemonicImportViewModel.Mnemonic {
        
        let prefixForPotentialwords = findPrefixForPotentialWords(
            for: mnemonic,
            selectedLocation: selectedLocation
        )
        let potentialWords = interactor.potentialMnemonicWords(
            for: prefixForPotentialwords
        )
        var wordsInfo = interactor.findInvalidWords(in: mnemonic)
        wordsInfo = updateWordsInfo(
            wordsInfo: wordsInfo,
            with: prefixForPotentialwords,
            at: selectedLocation
        )
        return .init(
            potentialWords: potentialWords,
            wordsInfo: wordsInfo,
            mnemonicToUpdate: updateMnemonic ? mnemonic : nil
        )
    }
    
    func findPrefixForPotentialWords(
        for mnemonic: String,
        selectedLocation: Int
    ) -> String {
        
        var prefix = ""
        for var i in 0..<mnemonic.count {
            let character = mnemonic[
                mnemonic.index(mnemonic.startIndex, offsetBy: i)
            ]
            if i == selectedLocation {
                return prefix
            }
            
            prefix.append(character)
            
            if character == " " {
                prefix = ""
            }
            
            i += 1
        }

        return prefix
    }
    
    func updateWordsInfo(
        wordsInfo: [MnemonicImportViewModel.Mnemonic.WordInfo],
        with prefixForPotentialwords: String,
        at selectedLocation: Int
    ) -> [MnemonicImportViewModel.Mnemonic.WordInfo] {
        
        var updatedWords = [MnemonicImportViewModel.Mnemonic.WordInfo]()
        
        var location = 0
        var wordUpdated = false
        
        for (index, wordInfo) in wordsInfo.enumerated() {
            location += wordInfo.word.count
            if selectedLocation <= location, !wordUpdated {
                if wordInfo.word == prefixForPotentialwords {
                    let isInvalid = index > 11
                        ? wordInfo.isInvalid
                        : !interactor.isValidPrefix(wordInfo.word)
                    
                    updatedWords.append(
                        .init(
                            word: wordInfo.word,
                            isInvalid: isInvalid
                        )
                    )
                }
                wordUpdated = true
            } else {
                updatedWords.append(wordInfo)
            }
            
            location += 1
        }
        
        return updatedWords
    }
}
