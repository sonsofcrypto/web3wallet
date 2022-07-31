// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewCell: UICollectionViewCell {

    override var isSelected: Bool {
        didSet { setSelected(isSelected) }
    }

    private (set) var bottomSeparatorView: UIView!
    
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
}

private extension CollectionViewCell {

    func configureUI() {
        clipsToBounds = false
        backgroundColor = Theme.colour.cellBackground
        layer.cornerRadius = Theme.constant.cornerRadius
        configureSeparator()
        setSelected(isSelected)
    }

    func configureSeparator() {
        
        let separator = UIView()
        separator.backgroundColor = Theme.colour.separatorTransparent
        contentView.addSubview(separator)
        separator.addConstraints(
            [
                .layout(
                    anchor: .leadingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 1)),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .trailingAnchor)
            ]
        )
        self.bottomSeparatorView = separator
        
        separator.isHidden = true
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
            layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
        }
    }
}
