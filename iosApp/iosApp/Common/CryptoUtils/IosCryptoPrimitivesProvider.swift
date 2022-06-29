// Created by web3d3v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib
import CoreCrypto

// Wrapper around coreCrypto functions
class IosCryptoPrimitivesProvider: CryptoPrimitivesProvider {

    func secureRand(size: Int32) throws -> KotlinByteArray {
        var error: NSError? = nil

        guard let data = CoreCryptoSecureRand(Int(size), &error) else {
            fatalError(error?.description ?? "Failed CorecryptoSecureRand")
        }

        return data.byteArray()
    }

    func compressedPubKey(curve: Curve, prv: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoCompressedPubKey(curveInt(curve), prv.data()) else {
            fatalError("Failed to derive compressed public key")
        }

        return data.byteArray()
    }

    func sha256(data: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoHash(data.data(), hashFnInt(.sha256)) else {
            fatalError("Failed keccak256")
        }

        return data.byteArray()
    }

    func sha512(data: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoHash(data.data(), hashFnInt(.sha512)) else {
            fatalError("Failed keccak512")
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

    func ripemd160(data: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoHash(data.data(), hashFnInt(.ripemd160)) else {
            fatalError("Failed keccak512")
        }

        return data.byteArray()
    }

    func hmacSha512(key: KotlinByteArray, data: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoHmacSha512(key.data(), data.data()) else {
            fatalError("Failed keccak512")
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

    func addPrvKeys(curve: Curve, key1: KotlinByteArray, key2: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoAddPrivKeys(curveInt(curve), key1.data(), key2.data()) else {
            fatalError("Failed keccak512")
        }

        return data.byteArray()
    }
    
    func addPubKeys(curve: Curve, key1: KotlinByteArray, key2: KotlinByteArray) -> KotlinByteArray {
        guard let data = CoreCryptoAddPubKeys(curveInt(curve), key1.data(), key2.data()) else {
            fatalError("Failed keccak512")
        }

        return data.byteArray()
    }

    func isBip44ValidPrv(curve: Curve, key: KotlinByteArray) -> Bool {
        CoreCryptoIsBip44ValidPrv(curveInt(curve), key.data())
    }
    
    func isBip44ValidPub(curve: Curve, key: KotlinByteArray) -> Bool {
        CoreCryptoIsBip44ValidPub(curveInt(curve), key.data())
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
        case .keccak256:
            return Int(CoreCryptoHashFnKeccak256)
        case .keccak512:
            return Int(CoreCryptoHashFnKeccak512)
        case .ripemd160:
            return Int(CoreCryptoHashFnRipemd160)
        default:
            fatalError(String(format: "Unsupported `hashFn` %s", hashFn))
        }
    }

    func curveInt(_ curve: Curve) -> Int {
        switch curve {
        case .secp256k1:
            return Int(CoreCryptoCurveSecp256k1)
        default:
            fatalError("Unimplemented curve \(curve)")
        }
    }
}
