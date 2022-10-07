// Created by web3d4v on 24/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalStatus: UIView {
    private (set) weak var label: UILabel!
    
    var text: String = "" {
        didSet { label.text = text }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    func configureUI() {
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        layer.borderWidth = 0.5
        layer.borderColor = Theme.colour.fillQuaternary.cgColor
        
        let label = UILabel()
        label.apply(style: .footnote, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        self.label = label
        label.addConstraints(
            [
                .layout(anchor: .topAnchor, constant: .equalTo(constant: 4)),
                .layout(anchor: .bottomAnchor, constant: .equalTo(constant: 4)),
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: 8)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: 8))
            ]
        )
    }
}
