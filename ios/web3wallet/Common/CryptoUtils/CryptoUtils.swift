// Created by web3d3v on 23/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import CommonCrypto

enum CryptoError: Error {
    case cryptoError(msg: String)
}

enum CryptOp  {
    case encrypt
    case decrypt
    
    func ccOp() -> CCOperation {
        switch self {
        case .encrypt:
            return CCOperation(kCCEncrypt)
        case .decrypt:
            return CCOperation(kCCDecrypt)
        }
    }
}


// MARK: - aesCTR

func aesCTR(key: Data, data: Data, iv: Data, op: CryptOp = .encrypt) throws -> Data {
    var cryptor: CCCryptorRef! = nil
    var status: CCCryptorStatus = 0;
    let ivBytes = NSData(data: iv).bytes
    let keyBytes = NSData(data: key).bytes
    let dataBytes = NSData(data: data).bytes

    status = CCCryptorCreateWithMode(
        op.ccOp(),
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

func pbkdf2(
    _ password: String,
    salt: Data,
    length: Int,
    rounds: Int,
    algorithm: Pbkdf2Algorithm = .hmacSHA256
) -> Data? {
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
        algorithm.ccAlgorithm(),
        UInt32(rounds),
        keyBytes,
        length
    )

    guard status == 0 else {
        return nil
    }

    return Data(derivedKey)
}

enum Pbkdf2Algorithm {
    case hmacSHA256
    case hmacSHA512

    func ccAlgorithm() -> CCPseudoRandomAlgorithm {
        switch self {
        case .hmacSHA512:
            return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA512)
        case .hmacSHA256:
            return CCPseudoRandomAlgorithm(kCCPRFHmacAlgSHA256)
        }
    }
}

// MARK: - Cryptographically secure randomness

extension Data {

    typealias UMBPtr = UnsafeMutableRawBufferPointer

    static func secRandom(_ count: Int) throws -> Data {
        var data = Data(count: count)
        let status = data.withUnsafeMutableBytes { (bytes: UMBPtr) -> Int32 in
            guard let addr = bytes.baseAddress else {
                return -1
            }

            return SecRandomCopyBytes(
                kSecRandomDefault,
                count,
                addr
            )
        }

        guard status == errSecSuccess else {
            throw SecRandDataError.failedSecRand
        }

        return data
    }

    enum SecRandDataError: Error {
        case failedSecRand
    }
}
