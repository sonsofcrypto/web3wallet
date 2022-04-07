//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.layer.applyHighlighted(self?.isSelected ?? false)
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.01) { [weak self] in
                self?.layer.applyHighlighted(self?.isHighlighted ?? false)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.applyShadowPath(bounds, radius: layer.cornerRadius)
    }

    private func configureUI() {
        backgroundColor = Theme.current.background
        layer.applyRectShadow()
        layer.applyBorder()
        configure(for: false)
    }

    private func configure(for selected: Bool) {
        layer.shadowOpacity = selected ? 1 : 0
        layer.borderColor = ( selected
            ? Theme.current.tintPrimary
            : Theme.current.tintPrimaryLight
        ).cgColor
    }
}
