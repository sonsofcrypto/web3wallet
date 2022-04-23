// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import CommonCrypto

enum CryptoError: Error {
    case cryptoError(msg: String)
}

// MARK: - aesCTR

func aesCTR(key: Data, data: Data, iv: Data) throws -> Data {
    var cryptor: CCCryptorRef! = nil
    var status: CCCryptorStatus = 0;
    let ivBytes = NSData(data: iv).bytes
    let keyBytes = NSData(data: key).bytes
    let dataBytes = NSData(data: data).bytes

    status = CCCryptorCreateWithMode(
        CCOperation(kCCEncrypt),
        CCMode(kCCModeCTR),
        CCAlgorithm(kCCAlgorithmAES),
        CCPadding(ccNoPadding),
        ivBytes,
        keyBytes,
        kCCKeySizeAES128,
        nil,
        0,
        0,
        CCModeOptions(kCCModeOptionCTR_BE),
        &cryptor
    )

    if cryptor == nil || status != kCCSuccess {
        CCCryptorRelease(cryptor)
        throw CryptoError.cryptoError(msg: "CCCryptorCreate error: \(status)")
    }

    let outputLen = CCCryptorGetOutputLength(cryptor, data.count, true)

    guard var dataOut = NSMutableData(length: outputLen) else {
        throw CryptoError.cryptoError(msg: "Failed to allocate data")
    }

    var dataOutBytes = dataOut.mutableBytes
    var dataOutMoved: size_t = 0;
    var dataOutMovedTotal: size_t = 0;

    status = CCCryptorUpdate(
        cryptor,
        dataBytes,
        data.count,
        dataOutBytes,
        outputLen,
        &dataOutMoved
    )

    dataOutMovedTotal += dataOutMoved

    if status != kCCSuccess {
        CCCryptorRelease(cryptor);
        throw CryptoError.cryptoError(msg: "CCCryptorUpdate error: \(status)")
    }

    CCCryptorFinal(
        cryptor,
        dataOutBytes + dataOutMoved,
        outputLen - dataOutMoved,
        &dataOutMoved
    )

    if status != kCCSuccess {
        CCCryptorRelease(cryptor);
        throw CryptoError.cryptoError(msg: "CCCryptorFinal error: \(status)")
    }

    CCCryptorRelease(cryptor)
    dataOutMovedTotal += dataOutMoved

    return Data(bytes: dataOutBytes, count: dataOutMovedTotal)
}

// MARK: - PBKDF2

func pbkdf2(_ password: String, salt: Data, length: Int, rounds: Int) -> Data? {
    guard let passwordData = password.data(using: .utf8) else {
        return nil
    }

    var derivedKey = NSMutableData(data: Data(repeating: 0, count: length))
    var keyBytes = derivedKey.mutableBytes
    let saltBytes = NSData(data: salt).bytes

    let status = CCKeyDerivationPBKDF(
        CCPBKDFAlgorithm(kCCPBKDF2),
        password,
        passwordData.count,
        saltBytes,
        salt.count,
        CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256),
        UInt32(rounds),
        keyBytes,
        length
    )

    guard status == 0 else {
        return nil
    }

    return Data(derivedKey)
}

// MARK: - Cryptographically secure randomness

extension Data {

    static func secRandom(_ count: Int) throws -> Data {
        var bytes = Data(count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, count, &bytes)

        if status == errSecSuccess {
            return bytes
        }

        throw SecRandDataError.failedSecRand
    }

    enum SecRandDataError: Error {
        case failedSecRand
    }
}
