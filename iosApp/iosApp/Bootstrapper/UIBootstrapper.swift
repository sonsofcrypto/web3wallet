// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class UIBootstrapper {
    
    private weak var window: UIWindow?
    
    init(window: UIWindow?) {
        
        self.window = window
    }
}

extension UIBootstrapper: Bootstrapper {
    
    func boot() {
        
        let rootWireframeFactory: RootWireframeFactory = ServiceDirectory.assembler.resolve()
        rootWireframeFactory.makeWireframe(in: window).present()
    }
}
