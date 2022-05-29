// Created by web3d3v on 29/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3lib
import CoreCrypto

class IosCryptoPrimitivesProvider: CryptoPrimitivesProvider {
    
    func secureRand(size: Int32) -> KotlinByteArray {
        var error: NSError? = nil
        
        guard let data = CoreCryptoSecureRand(Int(size), &error) else {
            fatalError(error?.description ?? "Failed CorecryptoSecureRand")
        }
        
        return KotlinByteArray(size: 0).from(data: data)
    }
}
