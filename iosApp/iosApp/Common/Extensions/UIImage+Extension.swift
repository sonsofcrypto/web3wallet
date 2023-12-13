// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import web3walletcore

extension UIImage {
    
    static func letterImage(_ letter: String, colors: [UIColor]) -> UIImage? {
        UIImage(systemName:"\(letter).circle.fill")?
            .applyingSymbolConfiguration(.init(paletteColors: colors))
    }

    func heightWidthRatio() -> CGFloat {
        size.height / size.width
    }

    func resize(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: .init(origin: .zero, size: size))
        }
    }
}
