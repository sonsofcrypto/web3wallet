// Created by web3d3v on 18/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3walletcore

protocol OnboardingService: AnyObject {

    func shouldCreateWalletAtFirstLaunch() -> Bool
    func shouldShowOnboardingButton() -> Bool
    func markDidInteractCardSwitcher()
}

// MARK: - DefaultOnboardingService

final class DefaultOnboardingService {

    let defaults: UserDefaults
    let signerStoreService: SignerStoreService
    let keyChainService: KeyChainService

    init(
        defaults: UserDefaults,
        signerStoreService: SignerStoreService,
        keyChainService: KeyChainService
    ) {
        self.defaults = defaults
        self.signerStoreService = signerStoreService
        self.keyChainService = keyChainService

        if shouldCreateWalletAtFirstLaunch() && signerStoreService.items().isEmpty {
            do {
                try createDefaultKeyStoreItem()
            } catch {
                do {
                    try createDefaultKeyStoreItem()
                } catch {
                    fatalError("Failed to generate default `KeyStoreItems`s \(error)")
                }
            }
        }
    }
}

extension DefaultOnboardingService: OnboardingService {

    func shouldCreateWalletAtFirstLaunch() -> Bool {
        return ServiceDirectory.onboardingMode == .oneTap
    }

    func shouldShowOnboardingButton() -> Bool {
        let didInteract = defaults.bool(forKey: Constant.didInteractCardSwitcher)
        return ServiceDirectory.onboardingMode == .oneTap && !didInteract
    }

    func markDidInteractCardSwitcher() {
        guard ServiceDirectory.onboardingMode == .oneTap else {
            return
        }
        defaults.set(true, forKey: Constant.didInteractCardSwitcher)
    }
}

private extension DefaultOnboardingService {

    func createDefaultKeyStoreItem(_ retry: Int = 3) throws {
        let worldList = WordList.english
        let bip39 = try Bip39.companion.from(
            entropySize: .es128,
            salt: "",
            worldList: worldList
        )
        let bip44 = try Bip44(seed: try bip39.seed(), version: .mainnetprv)
        let extKey = try bip44.deriveChildKey(path: derivationPath())
        let keyStoreItem = KeyStoreItem(
            uuid: UUID().uuidString,
            name: walletName(),
            sortOrder: (signerStoreService.items().last?.sortOrder ?? 0) + 100,
            type: .mnemonic,
            passUnlockWithBio: true,
            iCloudSecretStorage: true,
            saltMnemonic: false,
            passwordType: .bio,
            derivationPath: derivationPath(),
            addresses: addresses()
        )
        let password = try CipherKt.secureRand(size: 32).toHexString(prefix: false)
        let secretStorage = SecretStorage.companion.encryptDefault(
            id: keyStoreItem.uuid,
            data: extKey.key,
            password: password,
            address: address(extKey),
            mnemonic: bip39.mnemonic.joined(separator: " "),
            mnemonicLocale: bip39.worldList.localeString(),
            mnemonicPath: derivationPath()
        )
        signerStoreService.add(
            item: keyStoreItem,
            password: password,
            secretStorage: secretStorage
        )

    }

    func walletName() -> String {
        guard !signerStoreService.items().isEmpty else {
            return Localized("mnemonicNew.defaultWalletName")
        }

        return String(
            format: Localized("mnemonicNew.defaultNthWalletName"),
            signerStoreService.items().count
        )
    }

    // TODO: Get default derivation path
    func derivationPath() -> String {
        return "m/44'/60'/0'/0/0"
    }

    // TODO: Derive address for key
    func address(_ extKey: ExtKey) -> String {
        extKey.pub().toHexString(prefix:false)
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

private extension DefaultOnboardingService {

    enum Constant {
        static let didInteractCardSwitcher = "didInteractCardSwitcherKey"
    }
}
