//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

final class MainBootstrapper {
    
}

extension MainBootstrapper: Bootstrapper {
    
    func boot() {
        
        let bootstrappers: [Bootstrapper] = [
            AssemblerBootstrapper()
        ]
        bootstrappers.forEach { $0.boot() }
    }
}
