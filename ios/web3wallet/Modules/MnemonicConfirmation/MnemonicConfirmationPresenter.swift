// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UniformTypeIdentifiers

enum MnemonicConfirmationPresenterEvent {
    
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
        
        let viewModel = makeViewModel(for: "", selectedLocation: 0)
        view.update(with: viewModel)
    }

    func handle(_ event: MnemonicConfirmationPresenterEvent) {
        
        switch event {
            
        case let .mnemonicChanged(mnemonic, selectedLocation):
            
            let viewModel = makeViewModel(
                for: mnemonic,
                selectedLocation: selectedLocation
            )
            view.update(with: viewModel)

        case .confirm:
            
            wireframe.navigate(to: .dismiss)
        }
    }
}

private extension DefaultMnemonicConfirmationPresenter {
    
    func makeViewModel(
        for mnemonic: String,
        selectedLocation: Int
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
        let isMnemonicValid = service.isMnemonicValid(mnemonic)
        
        return .init(
            potentialWords: potentialWords,
            wordsInfo: wordsInfo,
            isValid: isMnemonicValid
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
        
        wordsInfo.forEach {
            
            location += $0.word.count
            
            if selectedLocation <= location, !wordUpdated {
                
                if $0.word == prefixForPotentialwords {
                    
                    updatedWords.append(
                        .init(
                            word: $0.word,
                            isInvalid: !service.isValidPrefix($0.word)
                        )
                    )
                }
                wordUpdated = true
            } else {
                
                updatedWords.append($0)
            }
            
            location += 1
        }
        
        return updatedWords
    }
}
