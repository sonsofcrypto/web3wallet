// Created by web3d3v on 20/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension CGSize {

    init(length: CGFloat) {
        self.init(width: length, height: length)
    }

    func sizeAddingToHeight(_ adjustment: CGFloat) -> CGSize {
        CGSize(width: width, height: height + adjustment)
    }

    func max(_ otherSize: CGSize) -> CGSize {
        otherSize.width >= width && otherSize.height >= height ? otherSize : self
    }
}

extension CGRect {

    var minXminY: CGPoint {
        CGPoint(x: minX, y: minY)
    }

    var midXY: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    init(zeroOrigin size: CGSize) {
        self.init(origin: .zero, size: size)
    }

    init(center: CGPoint, size: CGSize) {
        self.init(
            origin: .init(
                x: center.x - size.width / 2,
                y:  center.y - size.height / 2
            ),
            size: size
        )
    }
}

extension CGFloat {

    var half: CGFloat {
        self * 0.5
    }
}
