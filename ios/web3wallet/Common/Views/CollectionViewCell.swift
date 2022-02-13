// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.configure(for: self?.isSelected ?? false)
            }
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.configure(for: self?.isHighlighted ?? false)
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

    private func configureUI() {
        backgroundColor = Theme.current.background
        layer.cornerRadius = Global.cornerRadius
        layer.borderWidth = 1
        layer.shadowColor = Theme.current.tintPrimary.cgColor
        layer.shadowRadius = Global.shadowRadius
        layer.shadowOffset = .zero
        clipsToBounds = false
        layer.masksToBounds = false
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
