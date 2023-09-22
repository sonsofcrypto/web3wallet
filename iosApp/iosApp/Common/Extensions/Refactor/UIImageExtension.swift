//
// Created by anon on 22/09/2023.
//

import UIKit

extension UIImage {

    static func loadImage(named: String) -> UIImage? {
        UIImage(named: named) ??
        UIImage(systemName: named) ??
        nil
    }

    func resize(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: .init(origin: .zero, size: size))
        }
    }
}
