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
    
    func testBip39() {
        let words = [
            "come", "tunnel", "another", "solar", "album", "boil", "negative",
            "place", "dinosaur", "galaxy", "balcony", "clerk"
        ]
        let seed = "d30f19d47abba7646fccbb210dfe048c6b2cc68971440e480f55bbae3b26a7b390d4e49d0e49a7a80c8a3918511f63a1a7db704b7bff63b90b85cd5a729ba923"
        
        let mnemonic = Bip39(mnemonic: words)
        assert(
            try! mnemonic.seed().hexString() == seed,
            "Incorrect seed"
        )
    }
    
    func testBip39Entropy() {
        let entropy = try! Data.secRandom(16)
        let entropyStr = entropy.hexString()
        
        let menemonic = try! Bip39(entropy).mnemonic
        let derivedEntropy = try! Bip39(mnemonic: menemonic).entropy()

        assert(
            entropy == derivedEntropy,
            String(
                format: "Entropy does not match:\n%@\n%@",
                entropyStr,
                derivedEntropy.hexString()
            )
        )
    }
}
