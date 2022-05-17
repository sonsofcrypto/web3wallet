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
