// Created by web3d3v on 14/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import XCTest
import CommonCrypto

class Web3SecretStorageTests: XCTestCase {


    func testEncryptDecrypt() throws {
        let input = "Let try to encrypt this ok are w"
        let password = "password"
        let data = String(input).data(using: .utf8)!

        let secureStorage = try! Web3SecretStorage.encrypt(data, password: "password")
        let decypted = try! secureStorage.decrypt(password)
        let output = String(data: decypted, encoding: .utf8)
        
        assert(
            input == output,
            String(format: "Input does not equal output\n%@\n%@", input, output ?? "")
        )
    }
    
    func testHexString() {
        let input = "Let try to encrypt this ok are w"
        let data = String(input).data(using: .utf8)!
        let hexStr = data.hexString()
        let fromHex = Data.fromHexString(hexStr)!
        let output = String(data: fromHex, encoding: .utf8)!
        assert(
            input == output,
            String(format: "Input does not equal output\n%@\n%@", input, output)
        )
    }
    
    func testWriteWeb3SecretStorage() throws {
        let password = "password"
        let data = String("Let try to encrypt this ok are w").data(using: .utf8)!
        let secureStorage = try! Web3SecretStorage.encrypt(data, password: password)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let json = try! encoder.encode(secureStorage)
        let str = String(data: json, encoding: .utf8)
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )
        .last?
        .appending("/test.json")
        
        print(path ?? "")
        try? str?.write(toFile: path!, atomically: true, encoding: .utf8)
    }
}
