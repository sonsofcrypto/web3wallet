// Created by web3d3v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib

// Wrapper around coreCrypto functions
class IosCryptoPrimitivesProvider {

    func secureRand(size: Int32) throws -> KotlinByteArray {
        try secureRand(size: size)
    }

    func compressedPubKey(curve: Curve, prv: KotlinByteArray) -> KotlinByteArray {
        compressedPubKey(curve: curve, prv: prv)
    }

    func sha256(data: KotlinByteArray) -> KotlinByteArray {
        sha256(data: data)
    }

    func sha512(data: KotlinByteArray) -> KotlinByteArray {
        sha512(data: data)
    }

    func keccak256(data: KotlinByteArray) -> KotlinByteArray {
        keccak256(data: data)
    }

    func keccak512(data: KotlinByteArray) -> KotlinByteArray {
        keccak512(data: data)
    }

    func ripemd160(data: KotlinByteArray) -> KotlinByteArray {
        ripemd160(data: data)
    }

    func hmacSha512(key: KotlinByteArray, data: KotlinByteArray) -> KotlinByteArray {
        hmacSha512(key: key, data: data)
    }

    func pbkdf2(
        pswd: KotlinByteArray, salt: KotlinByteArray,
        iter: Int32, keyLen: Int32,
        hash: HashFn
    ) -> KotlinByteArray {
        pbkdf2(pswd: pswd, salt: salt, iter: iter, keyLen: keyLen, hash: hash)
    }

    func addPrvKeys(curve: Curve, key1: KotlinByteArray, key2: KotlinByteArray) -> KotlinByteArray {
        addPrvKeys(curve: curve, key1: key1, key2: key2)
    }
    
    func addPubKeys(curve: Curve, key1: KotlinByteArray, key2: KotlinByteArray) -> KotlinByteArray {
        addPubKeys(curve: curve, key1: key1, key2: key2)
    }

    func isBip44ValidPrv(curve: Curve, key: KotlinByteArray) -> Bool {
        isBip44ValidPrv(curve: curve, key: key)
    }
    
    func isBip44ValidPub(curve: Curve, key: KotlinByteArray) -> Bool {
        isBip44ValidPub(curve: curve, key: key)
    }
}
