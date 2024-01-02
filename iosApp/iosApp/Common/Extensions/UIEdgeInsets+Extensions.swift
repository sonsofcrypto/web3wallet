// Created by web3d3v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIEdgeInsets {

    static func with(
        top: CGFloat = 0,
        left: CGFloat = 0,
        bottom: CGFloat = 0,
        right: CGFloat = 0
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    static func with(all: CGFloat = 0) -> UIEdgeInsets {
        UIEdgeInsets(top: all, left: all, bottom: all, right: all)
    }

    func horizontal() -> CGFloat {
        left + right
    }
}
