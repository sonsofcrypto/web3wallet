// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class CollectionViewCell: UICollectionViewCell {

    var cornerStyle: Style = .single {
        didSet { update(for: cornerStyle) }
    }

//    override var isSelected: Bool {
//        didSet {
//            UIView.animate(withDuration: 0.1) { [weak self] in
//                self?.layer.applyHighlighted(self?.isSelected ?? false)
//            }
//        }
//    }

//    override var isHighlighted: Bool {
//        didSet {
//            UIView.animate(withDuration: 0.01) { [weak self] in
//                self?.layer.applyHighlighted(self?.isHighlighted ?? false)
//            }
//        }
//    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

//    override func layoutSubviews() {
//        super.layoutSubviews()
//        //layer.applyShadowPath(bounds, radius: layer.cornerRadius)
//    }

    private func configureUI() {
        
        layer.cornerRadius = Theme.constant.cornerRadius
        backgroundColor = Theme.colour.labelQuaternary
        //layer.applyRectShadow()
        //layer.applyBorder()
        //configure(for: false)
    }

//    private func configure(for selected: Bool) {
//        layer.shadowOpacity = selected ? 1 : 0
//        layer.borderColor = ( selected
//            ? Theme.colour.fillPrimary
//            : Theme.colour.fillTertiary
//        ).cgColor
//    }
}

// MARK: - Style

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
