// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

enum MnemonicUpdateInteractorError: Error {
    case failedCreateBip39Bip44
    case failedToLoadSecretStorageData
}

protocol MnemonicUpdateInteractor: AnyObject {
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

    /// See if passwords meets minimum specs
    func isValidPassword(password: String) -> Bool

    /// Creates new `KeyStoreItem` and saves it to `KeyStore`
    func createKeyStoreItem(_ password: String, salt: String) throws -> KeyStoreItem
}

// MARK: - DefaultMnemonicUpdateInteractor

final class DefaultMnemonicUpdateInteractor {

    var entropySize: Bip39.EntropySize = .es128
    var name: String = ""
    var passUnlockWithBio: Bool = true
    var iCloudSecretStorage: Bool = true
    var saltMnemonic: Bool = false
    var passwordType: KeyStoreItem.PasswordType = .bio
    var derivationPath: String = "m/44'/60'/0'/0/0" // TODO: Get default derivations path from wallet

    private(set) var mnemonic = [String]()
    private(set) var locale = "en"

    private var bip39: Bip39!
    private var keyStoreService: KeyStoreService

    init(_ keyStoreService: KeyStoreService) {
        self.keyStoreService = keyStoreService
    }
}

// MARK: - DefaultTemplateInteractor

extension DefaultMnemonicUpdateInteractor: MnemonicUpdateInteractor {

    func generateNewMnemonic() {
        do {
            let (bip39, bip44) = try bip39bip44()
            self.bip39 = bip39
            mnemonic = bip39.mnemonic
            locale = bip39.worldList.localeString()
        } catch {
            fatalError("Failed to create bip39, bip44. \(error)")
        }
    }

    func createKeyStoreItem(_ password: String, salt: String) throws -> KeyStoreItem {
        let worldList = wordList(locale)
        let bip39 = Bip39(mnemonic: mnemonic, salt: salt, worldList: worldList)
        let bip44 = try Bip44(seed: try bip39.seed(), version: .mainnetprv)
        let extKey = try bip44.deviceChildKey(path: derivationPath)
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
            addresses: addresses()
        )
        let secretStorage = SecretStorage.companion.encryptDefault(
            id: keyStoreItem.uuid,
            data: extKey.key,
            password: password,
            address: address(extKey),
            w3wParams: SecretStorage.W3WParams(mnemonicLocale: locale)
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
}

private extension DefaultMnemonicUpdateInteractor {

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

    // TODO: Derive address for key
    func address(_ extKey: ExtKey) -> String {
        extKey.pub().toHexString()
    }

    // TODO: Derive addresses
    func addresses() -> [String: String] {
        let addresses = [String: String]()
        return addresses
    }

    // TODO: Get default paths from `Network`/`Wallet`
    func defaultDerivationsPaths() -> [String] {
        [
            "m/44'/60'/0'/0/0",
            "m/44'/501'/0'/0/0",
            "m/44'/354'/0'/0/0",
        ]
    }
}

// MARK: - Constant

private extension DefaultMnemonicUpdateInteractor {

    enum Constant {
        static let maxNameLength: Int = 24
    }
}
