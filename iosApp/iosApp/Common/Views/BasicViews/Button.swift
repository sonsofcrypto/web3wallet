// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

@IBDesignable
class Button: UIButton {

    @objc enum Kind: Int {
        case primary
        case secondary
        case destructive
    }

    @objc enum Variant: Int {
        case regular
        case compact
        case small
        case compactInCell
    }

    @objc enum ImagePosition: Int {
        case none
        case left
        case right
    }

    @IBInspectable var kind: Kind = .primary {
        didSet { applyTheme(Theme) }
    }
    
    @IBInspectable var imagePosition: ImagePosition = .none {
        didSet { applyTheme(Theme) }
    }
    
    @IBInspectable var variant: Variant = .regular {
        didSet { applyTheme(Theme) }
    }
    
    @IBInspectable var forceSingleLineText: Bool = false {
        didSet { applyTheme(Theme) }
    }

    convenience init(
        _ title: String? = nil,
        image: UIImage? = nil,
        kind: Kind = .primary,
        variant: Variant = .regular,
        imagePosition: ImagePosition = .none,
        forceSingleLineText: Bool = false
    ) {
        self.init(type: .custom)
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        self.kind = kind
        self.variant = variant
        self.imagePosition = imagePosition
        self.forceSingleLineText = forceSingleLineText
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        applyTheme(Theme)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if imagePosition == .left, let imgView = imageView {
            let padding = variant == .regular ? Theme.padding : Theme.paddingHalf
            let x = padding
            imgView.frame.origin.x = x
            guard let label = titleLabel else { return }
            label.frame.origin.x = imgView.frame.maxX + padding
            label.frame.size.width = bounds.width - padding - label.frame.minX
        }
        
        if variant == .compactInCell, let imgView = imageView {
            imgView.bounds.size.height = bounds.height - 8
            imgView.center.y = bounds.height.half
            imgView.contentMode = .scaleAspectFit
        }

        if forceSingleLineText {
            titleLabel?.numberOfLines = 1
            titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }

    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
    }

    func applyTheme(_ theme: ThemeProtocol) {
        setTitleColor(titleColor(theme), for: .normal)
        setTitleColor(titleDisabledColor(theme), for: .disabled)
        backgroundColor = bgColor(theme)
        tintColor = titleColor(theme)
        titleLabel?.font = titleFont(theme)
        layer.borderWidth = borderWidth(Theme)
        layer.borderColor = borderColor(Theme).cgColor
        layer.cornerRadius = cornerRadius(Theme)
    }

    func titleColor(_ theme: ThemeProtocol) -> UIColor {
        switch kind {
        case .primary: return theme.color.textPrimary
        case .secondary: return theme.color.textPrimary
        case .destructive: return theme.color.textPrimary
        }
    }

    func titleDisabledColor(_ theme: ThemeProtocol) -> UIColor {
        titleColor(theme).withAlpha(0.5)
    }

    func titleFont(_ theme: ThemeProtocol) -> UIFont {
        switch variant {
        case .regular: return Theme.font.title3
        case .compact, .compactInCell: return theme.font.callout
        case .small: return theme.font.footnote
        }
    }

    func bgColor(_ theme: ThemeProtocol) -> UIColor {
        switch kind {
        case .primary: return theme.color.buttonBgPrimary
        case .secondary: return theme.color.buttonBgSecondary
        case .destructive: return theme.color.destructive
        }
    }

    func borderWidth(_ theme: ThemeProtocol) -> CGFloat {
        1
    }

    func borderColor(_ theme: ThemeProtocol) -> UIColor {
        switch kind {
        case .primary: return theme.color.buttonBgPrimary
        case .secondary: return theme.color.textPrimary
        case .destructive: return theme.color.destructive
        }
    }

    func cornerRadius(_ theme: ThemeProtocol) -> CGFloat {
        theme.cornerRadius.half
//        switch variant {
//        case .compact, .compactInCell: return theme.cornerRadius.half
//        default: return theme.cornerRadius
//        }
    }

    override class func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override var isHighlighted: Bool {
        didSet {
            switch kind {
            case .secondary: layer.borderColor = isHighlighted
                ? titleLabel?.textColor.cgColor
                : borderColor(Theme).cgColor
            default: ()
            }
        }
    }
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        switch variant {
        case .regular: size.height = Theme.buttonHeight
        case .compact, .compactInCell: size.height = Theme.buttonInCellHeight
        case .small: size.height = Theme.buttonSmallHeight
        }
        return size
    }
}

extension ButtonViewModel.Kind {

    func toKind() -> Button.Kind {
        switch self {
        case .primary: return .primary
        case .secondary: return .secondary
        case .destructive: return .destructive
        default: return .secondary
        }
    }
}
