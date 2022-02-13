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
    
    private var store: [String: Any] = [:]
}

// MARK: - Store
extension DefaultStore: Store {

    func set<T>(_ val: T, key: String) throws where T: Codable {
//        createStoreIfNeeded()
//        let data = try Data(contentsOf: url)
//        let json = try JSONSerialization.jsonObject(
//            with: data,
//            options: .fragmentsAllowed
//        )
//
//        guard var dict = json as? Dictionary<String, Decodable> else {
//            throw StoreError.failedToReadStoreData
//        }
//
//        dict[key] = val
//        let newData = try JSONSerialization.data(withJSONObject: dict)
//        try newData.write(to: url, options: .atomic)
        store[key] = val
    }

    func get<T>(_ key: String) -> T? where T: Codable {
//        createStoreIfNeeded()
//        guard let data = try? Data(contentsOf: url) else {
//            return nil
//        }
//
//        let json = try? JSONSerialization.jsonObject(
//            with: data,
//            options: .fragmentsAllowed
//        )
//
//        return (json as? [String: Decodable])?[key] as? T
        return store[key] as? T
    }

    func createStoreIfNeeded() {
        guard !FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try? "{}".data(using: .utf8)!.write(to: url, options: .atomic)
    }
}

// MARK - StoreError

extension DefaultStore {

    enum StoreError: Error {
        case failedToReadStoreData
    }
    
}
