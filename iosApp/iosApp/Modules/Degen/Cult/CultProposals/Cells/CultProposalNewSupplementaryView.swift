// Created by web3d4v on 22/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalNewSupplementaryView: UICollectionReusableView {
    
    private weak var label: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
        backgroundColor = Theme.colour.candleGreen
        layer.cornerRadius = Theme.constant.cornerRadiusSmall
        
        let label = UILabel()
        label.apply(style: .callout, weight: .bold)
        label.text = "NEW"
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
