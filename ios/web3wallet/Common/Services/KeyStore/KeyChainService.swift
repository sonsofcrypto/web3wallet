// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import Security

protocol KeyChainService: AnyObject {

    func addItem(_ item: KeyStoreItem) throws
    func item(for: KeyStoreItem) throws -> Data?
    func removeItem(_ item: KeyStoreItem)
    func allKeyStoreItems() throws -> [Data]

    func generatePassword(_ id: String, sync: Bool) throws
    func addPassword(_ password: String, id: String, sync: Bool) throws
    func password(for id: String) throws -> String?
    func removePassword(id: String)
}

// MARK: - DefaultKeyChainService

class DefaultKeyChainService { }

// MARK: - KeyChainService

extension DefaultKeyChainService: KeyChainService {
    
    func addItem(_ item: KeyStoreItem) throws {
        guard let data = try item.secretStorage?.data() else {
            throw KeyChainError.failedToEncodeSecretStorage
        }
        let sync = item.iCloudSecretStorage
        try addItem(id: item.id, data: data, sync: sync, type: .secretStorage)
    }

    func item(for item: KeyStoreItem) throws -> Data? {
        return try self.item(for: item.id, type: .secretStorage)
    }

    func removeItem(_ item: KeyStoreItem) {
        removeItem(id: item.id, type: .secretStorage)
    }

    func allKeyStoreItems() throws -> [Data] {
        let query = [
            kSecAttrService: ItemType.secretStorage.rawValue,
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
            kSecMatchLimit: Constant.maxWalletCount,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        guard status == errSecSuccess, let items = result as? [NSDictionary] else {
            throw KeyChainError.failedToRetrieveItem
        }

        return items
            .map { $0[kSecValueData] as? Data }
            .compactMap { $0 }
    }
    
    func generatePassword(_ id: String, sync: Bool) throws {
        let password = (try Data.secRandom(16)).hexString()
        try addPassword(password, id: id, sync: sync)
    }
    
    func addPassword(_ password: String, id: String, sync: Bool) throws {
        guard let data = password.data(using: .utf8) else {
            throw KeyChainError.failedToEncodePasswordToData
        }
        try addItem(id: id, data: data, sync: sync, type: .password)
    }
    
    func password(for id: String) throws -> String? {
        guard let data = try item(for: id, type: .password),
              let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return password
    }

    func removePassword(id: String) {
        removeItem(id: id, type: .password)
    }
}

// MARK: - Utilities

extension DefaultKeyChainService {

    func addItem(id: String, data: Data, sync: Bool, type: ItemType) throws {
        let attributes = [
            kSecAttrAccount: id,
            kSecAttrService: type.rawValue,
            kSecClass: kSecClassGenericPassword,
            kSecValueData: data,
            kSecAttrSynchronizable: sync,
            kSecAttrAccessible: sync
                ? kSecAttrAccessibleAfterFirstUnlock
                : kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ] as CFDictionary

        let status = Security.SecItemAdd(attributes, nil)

        guard status == errSecSuccess else {
            throw type == .password
                ? KeyChainError.failedToStorePassword
                : KeyChainError.failedToStoreSecretStorage
        }
    }

    func removeItem(id: String, type: ItemType) {
        let query = [
            kSecAttrAccount: id,
            kSecAttrService: type.rawValue,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary

        guard SecItemCopyMatching(query, nil) != errSecItemNotFound  else {
            return
        }

        SecItemDelete(query as CFDictionary)
    }

    func item(for id: String, type: ItemType) throws -> Data? {
        let query = [
            kSecAttrAccount: id,
            kSecAttrService: type.rawValue,
            kSecClass: kSecClassGenericPassword,
            kSecAttrSynchronizable: kSecAttrSynchronizableAny,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)

        guard status == errSecSuccess, let info = result as? NSDictionary else {
            throw KeyChainError.failedToRetrieveItem
        }

        return info[kSecValueData] as? Data
    }
}

// MARK: - Error

extension DefaultKeyChainService {

    enum KeyChainError: Error {
        case failedToStoreSecretStorage
        case failedToStorePassword
        case failedToEncodeSecretStorage
        case failedToEncodePasswordToData
        case failedToRetrieveItem
    }
}

// MARK: - ItemType

extension DefaultKeyChainService {

    enum ItemType: String {
        case password = "com.sonsOfCrypto.web3Wallet.password"
        case secretStorage = "com.sonsOfCrypto.web3Wallet.secreteStorage"
    }
}

// MARK: - Constant

extension DefaultKeyChainService {

    enum Constant {
        static let maxWalletCount = 100000000
    }

}
