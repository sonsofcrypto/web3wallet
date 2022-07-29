// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UniformTypeIdentifiers

enum MnemonicConfirmationPresenterEvent {
    
    case dismiss
    case mnemonicChanged(
        to: String,
        selectedLocation: Int
    )
    case confirm
}

protocol MnemonicConfirmationPresenter: AnyObject {

    func present()
    func handle(_ event: MnemonicConfirmationPresenterEvent)
}

final class DefaultMnemonicConfirmationPresenter {

    private let view: MnemonicConfirmationView
    private let wireframe: MnemonicConfirmationWireframe
    private let service: MnemonicConfirmationService
    
    private var ctaTapped = false
    private var mnemonic = ""
    private var selectedLocation = 0

    init(
        view: MnemonicConfirmationView,
        wireframe: MnemonicConfirmationWireframe,
        service: MnemonicConfirmationService
    ) {
        self.view = view
        self.wireframe = wireframe
        self.service = service
    }
}

extension DefaultMnemonicConfirmationPresenter: MnemonicConfirmationPresenter {

    func present() {
        
        refresh()
    }

    func handle(_ event: MnemonicConfirmationPresenterEvent) {
        
        switch event {
            
        case .dismiss:
            
            wireframe.navigate(to: .dismiss)
            
        case let .mnemonicChanged(mnemonicIn, selectedLocationIn):
            
            let tuple = clearBlanksFromFrontOf(mnemonicIn, with: selectedLocationIn)
            
            self.mnemonic = tuple.mnemonic
            self.selectedLocation = tuple.selectedLocation
            refresh(updateMnemonic: mnemonicIn != mnemonic)

        case .confirm:
            
            guard ctaTapped else {
                
                ctaTapped = true
                refresh()
                return
            }
            
            ctaTapped = true

            guard service.isMnemonicValid(mnemonic) else {
                
                refresh()
                return
            }
            
            service.markDashboardNotificationAsComplete()
            
            wireframe.navigate(to: .dismiss)
        }
    }
}

private extension DefaultMnemonicConfirmationPresenter {
    
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
    
    func refresh(updateMnemonic: Bool = false) {
        
        let viewModel = makeViewModel(updateMnemonic: updateMnemonic)
        view.update(with: viewModel)
    }
    
    func makeViewModel(
        updateMnemonic: Bool
    ) -> MnemonicConfirmationViewModel {
        
        let prefixForPotentialwords = findPrefixForPotentialWords(
            for: mnemonic,
            selectedLocation: selectedLocation
        )
        let potentialWords = service.potentialMnemonicWords(
            for: prefixForPotentialwords
        )
        var wordsInfo = service.findInvalidWords(in: mnemonic)
        wordsInfo = updateWordsInfo(
            wordsInfo: wordsInfo,
            with: prefixForPotentialwords,
            at: selectedLocation
        )
        let isMnemonicValid = service.isMnemonicValid(
            mnemonic.trimmingCharacters(in: .whitespaces)
        )
        
        return .init(
            potentialWords: potentialWords,
            wordsInfo: wordsInfo,
            isValid: ctaTapped ? isMnemonicValid : nil,
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
        wordsInfo: [MnemonicConfirmationViewModel.WordInfo],
        with prefixForPotentialwords: String,
        at selectedLocation: Int
    ) -> [MnemonicConfirmationViewModel.WordInfo] {
        
        var updatedWords = [MnemonicConfirmationViewModel.WordInfo]()
        
        var location = 0
        var wordUpdated = false
        
        for (index, wordInfo) in wordsInfo.enumerated() {
            
            location += wordInfo.word.count
            
            if selectedLocation <= location, !wordUpdated {
                
                if wordInfo.word == prefixForPotentialwords {
                    
                    let isInvalid = index > 11
                    ? wordInfo.isInvalid
                    : !service.isValidPrefix(wordInfo.word)
                    
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
