// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet { setSelected(isSelected) }
    }

    private(set) var bottomSeparatorView = LineView()
    var separatorViewLeadingPadding: CGFloat = Theme.constant.padding
    var separatorViewTrailingPadding: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    var cornerStyle: Style = .single {
        didSet { update(for: cornerStyle) }
    }

    func setSelected(_ selected: Bool) {
        layer.borderWidth = isSelected ? 1.0 : 0.0
        layer.borderColor = Theme.colour.labelPrimary.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        bottomSeparatorView.frame = CGRect(
            x: separatorViewLeadingPadding,
            y: bounds.maxY - 0.33,
            width: bounds.width - separatorViewLeadingPadding - separatorViewTrailingPadding,
            height: 0.33
        )
    }
}

private extension CollectionViewCell {

    func configureUI() {
        clipsToBounds = false
        backgroundColor = Theme.colour.cellBackground
        layer.cornerRadius = Theme.constant.cornerRadius
        contentView.addSubview(bottomSeparatorView)
        bottomSeparatorView.isHidden = true
        setSelected(isSelected)
    }
}

extension CollectionViewCell {

    enum Style {
        case top
        case bottom
        case middle
        case single
    }

    func update(for style: CollectionViewCell.Style) {
        switch style {
        case .top:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .middle:
            layer.maskedCorners = []
        case .single:
            layer.maskedCorners = .all
        }
    }
}
