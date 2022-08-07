// Created by web3d4v on 17/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIImage {
    
    static func loadImage(named: String) -> UIImage? {
        UIImage(named: named) ??
        UIImage(named: Theme.name + "-" + named) ??
        UIImage(systemName: named) ??
        nil
    }
        
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: .init(origin: .zero, size: size))
        }
    }

    func heightWidthwRatio() -> CGFloat {
        size.height / size.width
    }
}
