// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol MnemonicConfirmationService: AnyObject {
    
    func potentialMnemonicWords(for prefix: String?) -> [String]
    func findInvalidWords(in mnemonic: String?) -> [
        MnemonicConfirmationViewModel.WordInfo
    ]
    func isValidPrefix(_ prefix: String) -> Bool
    func isMnemonicValid(_ mnemonic: String) -> Bool
}

final class DefaultMnemonicConfirmationService {
    
    private let accountService: AccountService
    
    init(accountService: AccountService) {
        
        self.accountService = accountService
    }
}

extension DefaultMnemonicConfirmationService: MnemonicConfirmationService {
    
    func potentialMnemonicWords(for prefix: String?) -> [String] {
        
        guard let prefix = prefix else {
            
            return accountService.mnemonicWords
        }
        
        return accountService.mnemonicWords.filter { word in
            word.hasPrefix(prefix)
        }        
    }
    
    func findInvalidWords(in mnemonic: String?) -> [MnemonicConfirmationViewModel.WordInfo] {
        
        guard let mnemonic = mnemonic else { return [] }
        
        var wordsInfo = [MnemonicConfirmationViewModel.WordInfo]()

        var words = mnemonic.split(separator: " ")
        
        var lastWord: String?
        if let last = words.last, let lastCharacter = mnemonic.last, lastCharacter != " " {
            
            lastWord = String(last)
            words = words.dropLast()
        }
        
        // Validates that all words other than the last one (if we are still typing)
        // are valid
        for (index, item) in words.enumerated() {
            
            let word = String(item)
            
            var isWordValid = accountService.mnemonicWords.contains(word)
            
            if index > 11 {
                isWordValid = false
            }
            
            wordsInfo.append(.init(word: word, isInvalid: !isWordValid))
        }
        
        // In case we have not yet typed the entire last word, we check that the start of it
        // matches with a valid word
        if let lastWord = lastWord {
            
            var isValidPrefix = isValidPrefix(lastWord)
            
            if words.count > 11 { isValidPrefix = false }
            
            wordsInfo.append(.init(word: lastWord, isInvalid: !isValidPrefix))
        }
        
        return wordsInfo
    }
    
    func isValidPrefix(_ prefix: String) -> Bool {
        
        var isValidPrefix = false
        accountService.mnemonicWords.forEach { word in
            if word.hasPrefix(prefix) { isValidPrefix = true }
        }
        return isValidPrefix
    }
    
    func isMnemonicValid(_ mnemonic: String) -> Bool {
        
        accountService.validateMnemonic(with: mnemonic.trimmingCharacters(in: .whitespaces))
    }
}
