// Created by web3d4v on 12/04/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class LineView: UIView {

    enum LineStyle {
        case normal
        case transparent
        case custom(color: UIColor)
    }

    var style: LineStyle = .normal {
        didSet { applyTheme(Theme) }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    convenience init(style: LineStyle) {
        self.init(frame: .zero)
        self.style = style
    }
    
    func configureUI() {
        applyTheme(Theme)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
    }

    func applyTheme(_ theme: ThemeProtocol) {
        switch style {
        case .normal:
            backgroundColor = Theme.color.separator
        case .transparent:
            backgroundColor = Theme.color.collectionSeparator
        case let .custom(color):
            backgroundColor = color
        }
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height = Theme.lineHeight
        return size
    }
}

class TransparentLineView: LineView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        style = .transparent
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        style = .transparent
    }
}
