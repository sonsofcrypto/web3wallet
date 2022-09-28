// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

// MARK: - Bootstrapper

protocol Bootstrapper: AnyObject {
    func boot()
}

// MARK: - MainBootstrapper

final class MainBootstrapper { }

extension MainBootstrapper: Bootstrapper {

    func boot() {
        let bootstrappers: [Bootstrapper] = [
            AssemblerBootstrapper(),
        ]
        bootstrappers.forEach { $0.boot() }
    }
}

// MARK: - UIBootstrapper

final class UIBootstrapper {

    private weak var window: UIWindow?

    init(window: UIWindow?) {
        self.window = window
    }
}

extension UIBootstrapper: Bootstrapper {

    func boot() {
        let rootWireframeFactory: RootWireframeFactory = ServiceDirectory.assembler.resolve()
        rootWireframeFactory.make(window).present()
    }
}
