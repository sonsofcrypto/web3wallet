// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIImage {
    
    static func letterImage(_ letter: String, colors: [UIColor]) -> UIImage? {
        UIImage(systemName:"\(letter).circle.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: colors))
    }

    func heightWidthRatio() -> CGFloat {
        size.height / size.width
    }
}
