//
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT
//

import UIKit

class DefaultButton: UIButton {

    override var isHighlighted: Bool {
        didSet { layer.applyHighlighted(isHighlighted) }
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
        layer.applyShadowPath(bounds)
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = Constant.defaultButtonHeight
        return size
    }

    func configureUI() {
        backgroundColor = AppTheme.current.colors.background
        layer.applyRectShadow()
        layer.applyBorder()
        layer.applyHighlighted(false)
        titleLabel?.applyStyle(.callout)
        tintColor = AppTheme.current.colors.textColor
    }
}

// MARK: - Constants

private extension DefaultButton {
    
    enum Constant {
        static let defaultButtonHeight: CGFloat = 64
    }
}

// MARK: - LeftImageButton

class LeftImageButton: DefaultButton {

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

class LeftRightImageButton: DefaultButton {

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

class VerticalButton: DefaultButton {

    override func configureUI() {
        super.configureUI()
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
