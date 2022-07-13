// Created by web3d3v on 13/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class TransformView: UIView {

    override class var layerClass: AnyClass {
        return CATransformLayer.self
    }

    static let parentSublayerTransform:CATransform3D = {
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 500.0
        return transform
    }()

}