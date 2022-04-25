// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol Store {
    func set<T>(_ val: T, key: String) throws where T: Codable
    func get<T>(_ key: String) -> T? where T: Codable
}
