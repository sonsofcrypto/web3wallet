// Created by web3d4v on 31/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import Kingfisher

extension UIImageView {
    
    func load(url: String, placeholder: UIImage? = nil) {
        
        guard let url = URL(string: url) else { return }
        load(url: url)
    }
    
    func load(url: URL, placeholder: UIImage? = nil) {
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Theme.colour.fillTertiary
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        activityIndicator.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        
        kf.setImage(with: url) { _ in
            activityIndicator.removeFromSuperview()
        }
    }

    convenience init(named: String) {
        self.init(image: UIImage(named: named))
    }
}
