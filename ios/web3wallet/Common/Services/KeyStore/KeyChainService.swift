// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import Security

protocol KeyChainService: AnyObject {

    func addItem(_ item: KeyStoreItem, sync: Bool) throws
    func item(for: KeyStoreItem) throws -> Data?
    func isSyncItem(for item: KeyStoreItem) throws -> Bool
    func removeItem(_ item: KeyStoreItem)

    func generatePassword(_ id: String, sync: Bool) throws
    func addPassword(_ password: String, id: String, sync: Bool) throws
    func password(for id: String) throws -> String?
    func isSyncPassword(for id: String) throws -> Bool
    func removePassword(id: String)
}

// MARK: - DefaultKeyChainService

class DefaultKeyChainService { }

// MARK: - KeyChainService

extension DefaultKeyChainService: KeyChainService {
    
    func addItem(_ item: KeyStoreItem, sync: Bool) throws {
        guard let data = try item.secretStorage?.data() else {
            throw KeyChainError.failedToEncodeSecretStorage
        }
        try addItem(id: item.id, data: data, sync: sync, type: .secretStorage)
    }

    func item(for item: KeyStoreItem) throws -> Data? {
        (try self.item(for: item.id, type: .secretStorage)).0
    }

    func isSyncItem(for item: KeyStoreItem) throws -> Bool {
        (try self.item(for: item.id, type: .secretStorage)).1
    }
    
    func removeItem(_ item: KeyStoreItem) {
        removeItem(id: item.id, type: .secretStorage)
    }
    
    func generatePassword(_ id: String, sync: Bool) throws {
        guard let password = String(data: try Data.secRandom(32), encoding: .utf8) else {
            throw KeyChainError.failedToEncodePasswordToData
        }
        try addPassword(password, id: id, sync: sync)
    }
    
    func addPassword(_ password: String, id: String, sync: Bool) throws {
        guard let data = password.data(using: .utf8) else {
            throw KeyChainError.failedToEncodePasswordToData
        }
        try addItem(id: id, data: data, sync: sync, type: .password)
    }
    
    func password(for id: String) throws -> String? {
        let (data, _) = try item(for: id, type: .password)
        
        guard let data = data, let password = String(data: data, encoding: .utf8) else {
            return nil
        }

        return password
    }

    func isSyncPassword(for id: String) throws -> Bool{
        return (try self.item(for: id, type: .password)).1
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

    func item(for id: String, type: ItemType) throws -> (Data?, Bool) {
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

        let data = info[kSecValueData] as? Data
        let accessible = info[kSecAttrAccessible]
        let synchronizable = info[kSecAttrAccessible]
        let sync = (accessible as? Bool) == true
            ? true
            : synchronizable as? NSString == kSecAttrAccessibleAfterFirstUnlock

        return (data, sync)
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
