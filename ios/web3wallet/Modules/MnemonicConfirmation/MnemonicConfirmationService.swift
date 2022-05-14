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
        
        if let lastCharacter = mnemonic.last, lastCharacter != " " {
            
            words = words.dropLast()
        }
        
        words.forEach {
            
            let word = String($0)
            
            if !accountService.mnemonicWords.contains(word) {
                invalidWords.append(word)
            }
        }
        
        return invalidWords
    }
    
    func isMnemonicValid(_ mnemonic: String) -> Bool {
        
        accountService.validateMnemonic(with: mnemonic)
    }
}
