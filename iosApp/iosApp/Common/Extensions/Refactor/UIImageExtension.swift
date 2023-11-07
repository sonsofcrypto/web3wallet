//
// Created by anon on 22/09/2023.
//

import UIKit

extension UIImage {

    func resize(to size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: .init(origin: .zero, size: size))
        }
    }
}
