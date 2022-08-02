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
    func isMnemonicValid(_ mnemonic: String) -> Bool
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

        return wordsStarting(with: prefix)
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
            
            var isWordValid = wordsStarting(with: word).count > 0
            //var isWordValid = mnemonicWords.contains(word)
            
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
        
        !wordsStarting(with: prefix).isEmpty
    }
    
    func isMnemonicValid(_ mnemonic: String) -> Bool {
        
        validateMnemonic(with: mnemonic.trimmingCharacters(in: .whitespaces))
    }

    func markDashboardNotificationAsComplete() {

        // TODO: Improve
        web3Service.setNotificationAsDone(
            notificationId: "modal.mnemonic.confirmation"
        )
    }
}

private extension DefaultMnemonicConfirmationService {
    
    func wordsStarting(with word: String) -> [String] {
        validator.wordsStartingWith(prefix: word)
    }

    func validateMnemonic(with mnemonic: String) -> Bool {
        
        print("[TODO]: Validate mnemonic: [\(mnemonic)]")
        return true
//        let words = mnemonic.trimmingCharacters(in: .whitespacesAndNewlines)
//            .split(separator: " ")
//            .map { String($0) }
//
//        // This expected address
//        let expectedAddress = keyStoreService.selected?.addresses[Network.ethereum().defaultDerivationPath()]
//
//        // Thi
//        let bip39 = try Bip39(mnemonic: words, salt: "", worldList: .english)
//        let bip44 = try Bip44(seed: try bip39.seed(), version: .mainnetprv)
//        let extKey = try bip44.deriveChildKey(path: Network.ethereum().defaultDerivationPath())
//        let address = Network.ethereum().address(pubKey: extKey.pub()).toHexString(prefix: true)
//
//        // This is how you know
//        keyStoreService.selected?.saltMnemonic
//
//        return expectedAddress == address
    }
}

