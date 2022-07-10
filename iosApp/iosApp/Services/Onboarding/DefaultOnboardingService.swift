// Created by web3d3v on 18/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import web3lib

protocol OnboardingService: AnyObject {

    func shouldCreateWalletAtFirstLaunch() -> Bool
    func shouldShowOnboardingButton() -> Bool
    func markDidInteractCardSwitcher()
}

// MARK: - DefaultOnboardingService

final class DefaultOnboardingService {

    let settings: SettingsService
    let defaults: UserDefaults
    let keyStoreService: KeyStoreService
    let keyChainService: KeyChainService

    init(
        settings: SettingsService,
        defaults: UserDefaults,
        keyStoreService: KeyStoreService,
        keyChainService: KeyChainService
    ) {
        self.settings = settings
        self.defaults = defaults
        self.keyStoreService = keyStoreService
        self.keyChainService = keyChainService

        if shouldCreateWalletAtFirstLaunch() && keyStoreService.items().isEmpty {
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
        return settings.onboardingMode == .oneTap
    }

    func shouldShowOnboardingButton() -> Bool {
        let didInteract = defaults.bool(forKey: Constant.didInteractCardSwitcher)
        return settings.onboardingMode == .oneTap && !didInteract
    }

    func markDidInteractCardSwitcher() {
        guard settings.onboardingMode == .oneTap else {
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
        let extKey = try bip44.deviceChildKey(path: derivationPath())
        let keyStoreItem = KeyStoreItem(
            uuid: UUID().uuidString,
            name: walletName(),
            sortOrder: (keyStoreService.items().last?.sortOrder ?? 0) + 100,
            type: .mnemonic,
            passUnlockWithBio: true,
            iCloudSecretStorage: true,
            saltMnemonic: false,
            passwordType: .bio,
            derivationPath: derivationPath(),
            addresses: addresses()
        )
        let password = try CipherKt.secureRand(size: 32).toHexString()
        let secretStorage = SecretStorage.companion.encryptDefault(
            id: keyStoreItem.uuid,
            data: extKey.key,
            password: password,
            address: address(extKey),
            w3wParams: SecretStorage.W3WParams(mnemonicLocale: "en")
        )
        keyStoreService.add(
            item: keyStoreItem,
            password: password,
            secretStorage: secretStorage
        )

    }

    func walletName() -> String {
        guard !keyStoreService.items().isEmpty else {
            return Localized("newMnemonic.defaultWalletName")
        }

        return String(
            format: Localized("newMnemonic.defaultNthWalletName"),
            keyStoreService.items().count
        )
    }

    // TODO: Get default derivation path
    func derivationPath() -> String {
        return "m/44'/60'/0'/0/0"
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

private extension DefaultOnboardingService {

    enum Constant {
        static let didInteractCardSwitcher = "didInteractCardSwitcherKey"
    }
}

// MARK: - Assembler

final class OnboardingServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {
        registry.register(scope: .singleton) { resolver -> OnboardingService in
            DefaultOnboardingService(
                settings: resolver.resolve(),
                defaults: .standard,
                keyStoreService: resolver.resolve(),
                keyChainService: resolver.resolve()
            )
        }
    }
}
