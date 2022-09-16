// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol FeatureWireframeFactory {

    func makeWireframe(
        parent: UIViewController?,
        context: FeatureWireframeContext
    ) -> FeatureWireframe
}

final class DefaultFeatureWireframeFactory: FeatureWireframeFactory {

    func makeWireframe(
        parent: UIViewController?,
        context: FeatureWireframeContext
    ) -> FeatureWireframe {
        
        DefaultFeatureWireframe(
            parent: parent,
            context: context
        )
    }
}
