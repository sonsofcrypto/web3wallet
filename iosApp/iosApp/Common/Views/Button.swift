// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class Button: UIButton {
    
    var style: Style = .normal {
        didSet { configure(for: style) }
    }

    override var isHighlighted: Bool {
        didSet { layer.applyHighlighted(isHighlighted) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure(for: style)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure(for: style)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.applyShadowPath(bounds)
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        switch style {
        case .primary:
            size.height = Theme.constant.buttonPrimaryHeight
        case .dashboardAction:
            size.height = Theme.constant.buttonDashboardActionHeight
        case .normal:
            size.height = Constant.defaultButtonHeight
        }
        return size
    }

    
    func configure(for style: Style = .normal) {
        switch style {
        case .primary:
            backgroundColor = Theme.colour.buttonBackgroundPrimary
            tintColor = Theme.colour.labelPrimary
            layer.cornerRadius = Theme.constant.cornerRadiusSmall
            titleLabel?.font = Theme.font.title3
            setTitleColor(Theme.colour.labelPrimary, for: .normal)
        case .dashboardAction:
            backgroundColor = .clear
            tintColor = Theme.colour.labelPrimary
            layer.borderWidth = 0.5
            layer.borderColor = Theme.colour.labelPrimary.cgColor
            layer.cornerRadius = Theme.constant.cornerRadius
            titleLabel?.font = Theme.font.calloutBold
            setTitleColor(Theme.colour.labelPrimary, for: .normal)
            titleLabel?.textAlignment = .natural
            titleEdgeInsets = .init(top: 0, left: 8, bottom: 0, right: 0)
            imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 8)
        case .normal:
            backgroundColor = Theme.colour.backgroundBaseSecondary
            layer.applyRectShadow()
            layer.applyBorder()
            layer.applyHighlighted(false)
            titleLabel?.applyStyle(.callout)
            tintColor = Theme.colour.labelPrimary
        }
    }
}

extension Button {
    
    enum Style {
        case normal
        case primary
        case dashboardAction
    }
}

// MARK: - Constants

private extension Button {
    
    enum Constant {
        static let defaultButtonHeight: CGFloat = 64
    }
}

// MARK: - LeftImageButton

class LeftImageButton: Button {

    var padding: CGFloat = 4
    var titleLabelXOffset: CGFloat = -4

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let imageView = self.imageView, let label = self.titleLabel else {
            return
        }

        imageView.center.x = (imageView.bounds.width / 2) + padding
        label.frame = CGRect(
            x: imageView.frame.maxX + titleLabelXOffset,
            y: 0 + padding,
            width: bounds.width - imageView.frame.maxX - (padding * 2),
            height: bounds.height - (padding * 2)
        )
    }
}

// MARK: - LeftImageButton

class LeftRightImageButton: Button {

    var padding: CGFloat = 4
    var titleLabelXOffset: CGFloat = 0

    var rightImageView: UIImageView = .init()

    override func layoutSubviews() {
        super.layoutSubviews()

        if rightImageView.superview == nil {
            addSubview(rightImageView)
        }

        guard let imageView = self.imageView, let label = self.titleLabel else {
            return
        }

        let length = min(bounds.width, bounds.height) - padding * 2
        imageView.bounds.size = CGSize(width: length, height: length)

        rightImageView.sizeToFit()

        imageView.center.x = (imageView.bounds.width / 2) + padding
        imageView.center.y = bounds.height / 2

        rightImageView.center.x = bounds.width - ((imageView.bounds.width / 2) + padding)
        rightImageView.center.y = bounds.height / 2

        label.frame = CGRect(
            x: imageView.frame.maxX + titleLabelXOffset + padding,
            y: 0 + padding,
            width: rightImageView.frame.minX - padding * 2 - imageView.frame.maxX,
            height: bounds.height - (padding * 2)
        )
    }
}

class VerticalButton: Button {

    override func configure(for style: Style) {
        super.configure(for: style)
        titleLabel?.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let imageView = self.imageView, let label = self.titleLabel else {
            return
        }

        imageView.center.x = bounds.width / 2
        imageView.center.y = bounds.height * 0.3333

        // TODO: Remove this hack. Itroduced coz color and font were on being
        // set when setting from `AccountHeaderCell`
        label.applyStyle(.smallestLabelGlow)

        label.bounds.size.width = bounds.width
        label.bounds.size.height = bounds.height * 0.3333
        label.center.x = bounds.width / 2
        label.center.y = bounds.height - label.bounds.height / 2 - 4
    }
}
