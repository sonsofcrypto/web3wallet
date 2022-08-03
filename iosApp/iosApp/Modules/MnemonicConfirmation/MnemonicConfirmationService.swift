// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

protocol MnemonicConfirmationService: AnyObject {
    
    func potentialMnemonicWords(for prefix: String?) -> [String]
    func findInvalidWords(in mnemonic: String?) -> [
        MnemonicConfirmationViewModel.WordInfo
    ]
    func isValidPrefix(_ prefix: String) -> Bool
    func isMnemonicValid(
        _ mnemonic: String,
        salt: String?
    ) -> Bool
    func markDashboardNotificationAsComplete()
}

final class DefaultMnemonicConfirmationService {
    
    let keyStoreService: KeyStoreService
    let web3Service: Web3ServiceLegacy
    
    private lazy var validator: Trie = {
        let trie = Trie()
        WordList.english.words().forEach {
            trie.insert(word: $0)
        }
        return trie
    }()
    
    init(
        keyStoreService: KeyStoreService,
        web3Service: Web3ServiceLegacy
    ) {
        
        self.keyStoreService = keyStoreService
        self.web3Service = web3Service
    }
}

extension DefaultMnemonicConfirmationService: MnemonicConfirmationService {
    
    func potentialMnemonicWords(for prefix: String?) -> [String] {
        guard let prefix = prefix, !prefix.isEmpty else {
            return []
        }

        return validator.wordsStartingWith(prefix: prefix)
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
        words.forEach {

            let word = String($0)
            
            let isWordValid = validator.wordsStartingWith(prefix: word).count > 0
            
            wordsInfo.append(.init(word: word, isInvalid: !isWordValid))
        }
        
        // In case we have not yet typed the entire last word, we check that the start of it
        // matches with a valid word
        if let lastWord = lastWord {
            
            let isValidPrefix = isValidPrefix(lastWord)
            
            wordsInfo.append(.init(word: lastWord, isInvalid: !isValidPrefix))
        }
        
        return wordsInfo
    }
    
    func isValidPrefix(_ prefix: String) -> Bool {
        
        !validator.wordsStartingWith(prefix: prefix).isEmpty
    }
    
    func isMnemonicValid(
        _ mnemonic: String,
        salt: String?
    ) -> Bool {
        
        let words = mnemonic.trimmingCharacters(in: .whitespaces).split(
            separator: " "
        ).map { String($0) }
        
        guard Bip39.companion.isValidWordsCount(count: words.count.int32) else {
            return false
        }
        
        do {
            let bip39 = try Bip39(mnemonic: words, salt: salt ?? "", worldList: .english)
            _ = try Bip44(seed: try bip39.seed(), version: .mainnetprv)
            return true
        } catch {
            return false
        }
    }

    func markDashboardNotificationAsComplete() {

        // TODO: Improve
        web3Service.setNotificationAsDone(
            notificationId: "modal.mnemonic.confirmation"
        )
    }
}
