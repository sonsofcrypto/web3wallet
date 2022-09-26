// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum MnemonicNewInteractorError: Error {
    case failedCreateBip39Bip44
    case failedToLoadSecretStorageData
}

protocol MnemonicNewInteractor: AnyObject {
    /// Entropy size ie word count
    var entropySize: Bip39.EntropySize { get set }
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
    /// Mnemonic (words)
    var mnemonic: [String] { get }
    /// Locale of mnemonic
    var locale: String { get }
    /// generates new wallet mnemonic
    func generateNewMnemonic()
    /// generate password
    func generatePassword() -> String
    /// See if passwords meets minimum specs
    func isValidPassword(password: String) -> Bool
    /// Creates new `KeyStoreItem` and saves it to `KeyStore`
    func createKeyStoreItem(_ password: String, salt: String) throws -> KeyStoreItem
}

// MARK: - DefaultMnemonicNewInteractor

final class DefaultMnemonicNewInteractor {
    var entropySize: Bip39.EntropySize = .es128
    var name: String = ""
    var passUnlockWithBio: Bool = true
    var iCloudSecretStorage: Bool = false
    var saltMnemonic: Bool = false
    var passwordType: KeyStoreItem.PasswordType = .bio
    var derivationPath: String = Network.ethereum().defaultDerivationPath()
    
    private(set) var mnemonic = [String]()
    private(set) var locale = "en"
    private var bip39: Bip39!
    private var keyStoreService: KeyStoreService
    
    init(_ keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

// MARK: - DefaultTemplateInteractor

extension DefaultMnemonicNewInteractor: MnemonicNewInteractor {

    func generateNewMnemonic() {
        do {
            let (bip39, _) = try bip39bip44()
            self.bip39 = bip39
            mnemonic = bip39.mnemonic
            locale = bip39.worldList.localeString()
        } catch {
            fatalError("Failed to create bip39, bip44. \(error)")
        }
    }

    func generatePassword() -> String {
        let password = try! CipherKt.secureRand(size: 32)
        return String(data: password.toDataFull(), encoding: .ascii)
            ?? password.toHexString(prefix: false)
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
        // TODO(Sancho): Validate pass (Pin at least 6 digits, pass at least 8 alpha numeric)
        return true
    }
}

private extension DefaultMnemonicNewInteractor {

    func bip39bip44(_ retry: Int = 3) throws -> (Bip39, Bip44) {
        do {
            let bip39 = try Bip39.companion.from(
                entropySize: entropySize,
                salt: "",
                worldList: WordList.companion.fromLocaleString(locale: locale)
            )
            return (
                bip39,
                try Bip44(seed: try bip39.seed(), version: .mainnetprv)
            )
        } catch {
            guard retry > 0 else { throw error }
            return try bip39bip44(retry - 1)
        }
    }

    func wordList(_ localeString: String) -> WordList {
        WordList.companion.fromLocaleString(locale: localeString)
    }

    func walletName() -> String {
        guard name.isEmpty else { return name }
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

private extension DefaultMnemonicNewInteractor {
    enum Constant {
        static let maxNameLength: Int = 24
    }
}
