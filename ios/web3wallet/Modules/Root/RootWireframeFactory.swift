// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol RootWireframeFactory {

    func makeWireframe() -> RootWireframe
}

// MARK: - DefaultRootWireframeFactory

class DefaultRootWireframeFactory {

    private weak var window: UIWindow?

    init(
        window: UIWindow?
    ) {
        self.window = window
    }
}

// MARK: - RootWireframeFactory

extension DefaultRootWireframeFactory: RootWireframeFactory {

    func makeWireframe() -> RootWireframe {
        DefaultRootWireframe(window: window)
    }
}