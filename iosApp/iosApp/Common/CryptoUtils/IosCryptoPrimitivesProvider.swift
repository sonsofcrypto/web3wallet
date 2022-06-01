// Created by web3d3v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib
import CoreCrypto

// Wrapper around coreCrypto functions
class IosCryptoPrimitivesProvider: CryptoPrimitivesProvider {
    
    func secureRand(size: Int32) -> KotlinByteArray {
        var error: NSError? = nil
        
        guard let data = CoreCryptoSecureRand(Int(size), &error) else {
            fatalError(error?.description ?? "Failed CorecryptoSecureRand")
        }
        
        return data.byteArray()
    }

    func pbkdf2(
        pswd: KotlinByteArray, salt: KotlinByteArray,
        iter: Int32, keyLen: Int32,
        hash: HashFn
    ) -> KotlinByteArray {
        guard let data = CoreCryptoPbkdf2(
            pswd.data(), salt.data(),
            Int(iter), Int(keyLen),
            hashFnInt(hash)
        ) else {
            fatalError("Failed CoreCryptoPbkdf2")
        }
        
        return data.byteArray()
    }

    func keccak256(data: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoKeccak256(data.data()) else {
            fatalError("Failed keccak256")
        }

        return data.byteArray()
    }

    func keccak512(data: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoKeccak256(data.data()) else {
            fatalError("Failed keccak512")
        }

        return data.byteArray()
    }
}

// MARK: -

private extension IosCryptoPrimitivesProvider {

    func hashFnInt(_ hashFn: HashFn) -> Int {
        switch hashFn {
        case .sha256:
            return Int(CoreCryptoHashFnSha256)
        case .sha512:
            return Int(CoreCryptoHashFnSha512)
        default:
            fatalError(String(format: "Unsupported `hashFn` %s", hashFn))
        }
    }
}
