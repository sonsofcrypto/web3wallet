// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class DefaultStore {

    private lazy var encoder = JSONEncoder()
    private lazy var decoder = JSONDecoder()

    private lazy var url: URL = try! FileManager.default.url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
    ).appendingPathComponent("store.json")
}

extension DefaultStore: Store {

    func set<T>(_ val: T, key: String) throws where T: Codable {
        createStoreIfNeeded()
        let data = try Data(contentsOf: url)
        var json = try decoder.decode([String: AnyCodable].self, from: data)
        json[key] = AnyCodable(val)

        let newData = try encoder.encode(json)
        try newData.write(to: url, options: .atomic)
    }

    func get<T>(_ key: String) -> T? where T: Codable {
        createStoreIfNeeded()

        guard let data = try? Data(contentsOf: url) else {
            return nil
        }

        let json = try? decoder.decode([String: AnyCodable].self, from: data)

        if let array = json?[key]?.value as? Array<Any> {
            if let data = try? encoder.encode(AnyCodable(array)) {
                return try? decoder.decode(T.self, from: data)
            }
        }

        if let dictionary = json?[key]?.value as? Dictionary<String, Any> {
            if let data = try? encoder.encode(AnyCodable(dictionary)) {
                return try? decoder.decode(T.self, from: data)
            }
        }

        return json?[key]?.value as? T
    }

    func createStoreIfNeeded() {
        guard !FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        try? "{}".data(using: .utf8)!.write(to: url, options: .atomic)
    }
}

extension DefaultStore {

    enum StoreError: Error {
        case failedToReadStoreData
    }
    
}
