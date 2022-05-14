// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

protocol MnemonicConfirmationService: AnyObject {
    
    func findInvalidWords(in mnemonic: String?) -> [String]
    func isMnemonicValid(_ mnemonic: String) -> Bool
}

final class DefaultMnemonicConfirmationService {
    
    private let accountService: AccountService
    
    init(accountService: AccountService) {
        
        self.accountService = accountService
    }
}

extension DefaultMnemonicConfirmationService: MnemonicConfirmationService {
    
    func findInvalidWords(in mnemonic: String?) -> [String] {
        
        guard let mnemonic = mnemonic else { return [] }
        
        var invalidWords = [String]()

        var words = mnemonic.split(separator: " ")
        
        var lastWord: String?
        if let last = words.last, let lastCharacter = mnemonic.last, lastCharacter != " " {
            
            lastWord = String(last)
            words = words.dropLast()
        }
        
        // Validates that all words other than the last one (if we are still typing)
        // are valid
        words.forEach {
            
            let word = String($0)
            
            if !accountService.mnemonicWords.contains(word) {
                invalidWords.append(word)
            }
        }
        
        // In case we have not yet typed the entire last word, we check that the start of it
        // matches with a valid word
        if let lastWord = lastWord {
            
            var isValidPrefix = false
            accountService.mnemonicWords.forEach { word in
                if word.hasPrefix(lastWord) { isValidPrefix = true }
            }
            if !isValidPrefix {
                invalidWords.append(lastWord)
            }
        }
        
        return invalidWords
    }
    
    func isMnemonicValid(_ mnemonic: String) -> Bool {
        
        accountService.validateMnemonic(with: mnemonic.trimmingCharacters(in: .whitespaces))
    }
}
