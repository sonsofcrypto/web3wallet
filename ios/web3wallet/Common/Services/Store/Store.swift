// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Store {
    func set<T>(_ val: T, key: String) throws where T: Codable
    func get<T>(_ key: String) -> T? where T: Codable
}

class DefaultStore {

    private lazy var coder = JSONSerialization()
    private lazy var url: URL = try! FileManager.default.url(
        for: .documentationDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    ).appendingPathComponent("store.json")
}

// MARK: - Store
extension DefaultStore: Store {

    func set<T>(_ val: T, key: String) throws where T: Codable {
        let data = try Data(contentsOf: url)
        let json = try JSONSerialization.jsonObject(
            with: data,
            options: .fragmentsAllowed
        )

        guard var dict = json as? Dictionary<String, Decodable> else {
            throw StoreError.failedToReadStoreData
        }

        dict[key] = val
        let newData = try JSONSerialization.data(withJSONObject: dict)
        try newData.write(to: url, options: .atomic)
    }

    func get<T>(_ key: String) -> T? where T: Codable {
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        let json = try? JSONSerialization.jsonObject(
            with: data,
            options: .fragmentsAllowed
        )

        return (json as? [String: Decodable])?[key] as? T
    }
}

// MARK - StoreError

extension DefaultStore {

    enum StoreError: Error {
        case failedToReadStoreData
    }
    
}
