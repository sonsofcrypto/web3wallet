// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class DefaultButton: UIButton {

    override var isHighlighted: Bool {
        didSet { configure(for: isHighlighted) }
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
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: Constant.defaultButtonCornerRadius
        ).cgPath
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = Constant.defaultButtonHeight
        return size
    }
}

// MARK: - Configure UI

extension DefaultButton {

    func configureUI() {
        layer.cornerRadius = Constant.defaultButtonCornerRadius
        layer.borderWidth = 1
        layer.shadowColor = Theme.current.tintPrimary.cgColor
        layer.shadowRadius = Constant.defaultShadowRadius
        layer.shadowOffset = .zero

        backgroundColor = Theme.current.background
        tintColor = Theme.current.textColor

        titleLabel?.layer.shadowColor = Theme.current.tintSecondary.cgColor
        titleLabel?.layer.shadowOffset = .zero
        titleLabel?.layer.masksToBounds = false
        titleLabel?.layer.shadowRadius = Constant.defaultShadowRadius
        titleLabel?.layer.shadowOpacity = 1
        titleLabel?.font = Theme.current.callout

        configure(for: false)
    }

    func configure(for highlighted: Bool) {
        layer.borderColor = (highlighted
            ? Theme.current.tintPrimary
            : Theme.current.tintPrimaryLight).cgColor
        layer.shadowOpacity = highlighted ? 1 :0
    }
}

// MARK: - Constants

private extension DefaultButton {
    
    enum Constant {
        static let defaultButtonHeight: CGFloat = 64
        static let defaultButtonCornerRadius: CGFloat = 8
        static let defaultShadowRadius: CGFloat = 4
    }
}
