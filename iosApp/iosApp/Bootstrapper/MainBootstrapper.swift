// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

final class MainBootstrapper {
    
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        
        self.window = window
    }
}

extension MainBootstrapper: Bootstrapper {
    
    func boot() {
        
        let bootstrappers: [Bootstrapper] = [
            AssemblerBootstrapper(),
            UIBootstrapper(window: window)
        ]
        bootstrappers.forEach { $0.boot() }
    }
}
