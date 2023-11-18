// Created by web3d3v on 16/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class HStackView: UIStackView {

    convenience init(
        _ views: [UIView] = [],
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        spacing: CGFloat = 0
    ) {
        self.init(arrangedSubviews: views)
        self.axis = .horizontal
        self.distribution = distribution
        self.alignment = alignment
        self.spacing = spacing
    }
}

class VStackView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.axis = .vertical
    }

    convenience init(
        _ views: [UIView] = [],
        alignment: Alignment = .fill,
        distribution: Distribution = .fill,
        spacing: CGFloat = 0
    ) {
        self.init(arrangedSubviews: views)
        self.axis = .vertical
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        self.axis = .vertical
    }
}

extension UIStackView {

    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach { addArrangedSubview($0) }
    }
}
