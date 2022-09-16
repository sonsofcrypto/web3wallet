// Created by web3d4v on 31/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation
import UIKit

final class FeatureDetailImageView: UIView {
    
    private weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        removeAllSubview()
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        imageView.layer.cornerRadius = Theme.constant.cornerRadius
        imageView.clipsToBounds = true
        self.imageView = imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                topAnchor.constraint(equalTo: imageView.topAnchor),
                bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
                heightAnchor.constraint(equalTo: widthAnchor, multiplier: 675/1200)
            ]
        )
    }
    
    func update(with imageUrl: String) {
        guard let url = imageUrl.url else {
            isHidden = true
            return
        }
        isHidden = false
        imageView.load(url: url)
    }
}
