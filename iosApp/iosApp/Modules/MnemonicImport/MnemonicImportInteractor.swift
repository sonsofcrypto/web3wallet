// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum MnemonicImportInteractorError: Error {
    case invalidWordCount
    case failedToLoadSecretStorageData
}

protocol MnemonicImportInteractor: AnyObject {
    /// Bip39 mnemonic
    var mnemonic: [String] { get set }
    /// Name of the `KeyStoreItem`
    var name: String { get set }
    /// Allows using Biometrics instead of typing password in
    var passUnlockWithBio: Bool { get set }
    /// Store mnemonic on icloud
    var iCloudSecretStorage: Bool { get set }
    /// Uses custom salt to derive seed
    var saltMnemonic: Bool { get set }
    /// Password type [PIN, PASS, BIO]
    var passwordType: KeyStoreItem.PasswordType { get set }
    /// Account derivations path
    var derivationPath: String { get set}
    /// Locale of mnemonic
    var locale: String { get }

    /// Suggestions for word, if empty word is not valid bip39 word
    func suggestions(for word: String) -> [String]

    /// Returns nil if mnemonic is valid
    func mnemonicError(words: [String], salt: String) -> Error?

    /// See if passwords meets minimum specs
    func isValidPassword(password: String) -> Bool

    /// generate password
    func generatePassword() -> String

    /// Creates new `KeyStoreItem` and saves it to `KeyStore`
    func createKeyStoreItem(_ password: String, salt: String) throws -> KeyStoreItem
    
    
    func potentialMnemonicWords(for prefix: String?) -> [String]
    func findInvalidWords(in mnemonic: String?) -> [
        MnemonicImportViewModel.Mnemonic.WordInfo
    ]
    func isValidPrefix(_ prefix: String) -> Bool
}

// MARK: - DefaultMnemonicImportInteractor

final class DefaultMnemonicImportInteractor {

    var mnemonic = [String]()
    var name: String = ""
    var passUnlockWithBio: Bool = true
    var iCloudSecretStorage: Bool = false
    var saltMnemonic: Bool = false
    var passwordType: KeyStoreItem.PasswordType = .bio
    var derivationPath: String = Network.ethereum().defaultDerivationPath()

    private(set) var locale = "en"

    private lazy  var validator: Trie = {
        let trie = Trie()
        WordList.english.words().forEach {
            trie.insert(word: $0)
        }
        return trie
    }()

    private var bip39: Bip39!
    private var keyStoreService: KeyStoreService

    init(_ keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

// MARK: - DefaultTemplateInteractor

extension DefaultMnemonicImportInteractor: MnemonicImportInteractor {

    func suggestions(for word: String) -> [String] {
        return validator.wordsStartingWith(prefix: word)
    }

    func mnemonicError(words: [String], salt: String) -> Error? {
        guard Bip39.companion.isValidWordsCount(count: words.count.int32) else {
            return MnemonicImportInteractorError.invalidWordCount
        }

        do {
            let bip39 = try Bip39(mnemonic: mnemonic, salt: salt, worldList: .english)
            let _ = try Bip44(seed: try bip39.seed(), version: .mainnetprv)
            return nil
        } catch {
            return error
        }
    }

    func createKeyStoreItem(_ password: String, salt: String) throws -> KeyStoreItem {
        let worldList = wordList(locale)
        let bip39 = try Bip39(mnemonic: mnemonic, salt: salt, worldList: worldList)
        let bip44 = try Bip44(seed: try bip39.seed(), version: .mainnetprv)
        let extKey = try bip44.deriveChildKey(path: derivationPath)
        let keyStoreItem = KeyStoreItem(
            uuid: UUID().uuidString,
            name: walletName(),
            sortOrder: (keyStoreService.items().last?.sortOrder ?? 0) + 100,
            type: .mnemonic,
            passUnlockWithBio: passUnlockWithBio,
            iCloudSecretStorage: iCloudSecretStorage,
            saltMnemonic: saltMnemonic,
            passwordType: passwordType,
            derivationPath: derivationPath,
            addresses: addresses(bip44: bip44)
        )
        let secretStorage = SecretStorage.companion.encryptDefault(
            id: keyStoreItem.uuid,
            data: extKey.key,
            password: password,
            address: Network.ethereum()
                .address(pubKey: extKey.xpub())
                .toHexString(prefix: true),
            mnemonic: bip39.mnemonic.joined(separator: " "),
            mnemonicLocale: bip39.worldList.localeString(),
            mnemonicPath: derivationPath
        )
        keyStoreService.add(
            item: keyStoreItem,
            password: password,
            secretStorage: secretStorage
        )
        return keyStoreItem
    }

    func isValidPassword(password: String) -> Bool {
        // TODO(Enric): Validate pass (Pin at least 6 digits, pass at least 8 alpha numeric)
        return true
    }

    func generatePassword() -> String {
        let password = try! CipherKt.secureRand(size: 32)
        return String(data: password.toDataFull(), encoding: .ascii)
            ?? password.toHexString(prefix: false)
    }
    
    func potentialMnemonicWords(for prefix: String?) -> [String] {
        guard let prefix = prefix, !prefix.isEmpty else {
            return []
        }

        return validator.wordsStartingWith(prefix: prefix)
    }
    
    func findInvalidWords(in mnemonic: String?) -> [MnemonicImportViewModel.Mnemonic.WordInfo] {
        
        guard let mnemonic = mnemonic else { return [] }
        
        var wordsInfo = [MnemonicImportViewModel.Mnemonic.WordInfo]()

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
}

private extension DefaultMnemonicImportInteractor {

    func wordList(_ localeString: String) -> WordList {
        WordList.companion.fromLocaleString(locale: localeString)
    }

    func walletName() -> String {
        guard name.isEmpty else {
            return name
        }

        guard !keyStoreService.items().isEmpty else {
            return Localized("newMnemonic.defaultWalletName")
        }

        return String(
            format: Localized("newMnemonic.defaultNthWalletName"),
            keyStoreService.items().count
        )
    }

    func addresses(bip44: Bip44) -> [String: String] {
        var addresses = [String: String]()
        NetworksServiceCompanion().supportedNetworks().forEach {
            let path = $0.defaultDerivationPath()
            let xpub = try! bip44.deriveChildKey(path: path).xpub()
            addresses[path] = $0.address(pubKey: xpub).toHexString(prefix: true)
        }
        return addresses
    }
}

// MARK: - Constant

private extension DefaultMnemonicImportInteractor {

    enum Constant {
        static let maxNameLength: Int = 24
    }
}
