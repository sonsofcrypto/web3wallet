// Created by web3d4v on 01/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class NetworkHeaderCell: UICollectionReusableView {
    
    private weak var label: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        configureUI()
    }
}

private extension NetworkHeaderCell {
    
    func configureUI() {
        
        let label = UILabel()
        label.font = Theme.font.subheadline
        label.textColor = Theme.colour.labelSecondary
        label.numberOfLines = 0
        label.textAlignment = .center
        self.label = label
        addSubview(label)
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding * 2)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding * 2)),
                .layout(anchor: .topAnchor, constant: .equalTo(constant: Theme.constant.padding * 2)),
                .layout(anchor: .bottomAnchor)
            ]
        )
    }
}

extension NetworkHeaderCell {

    func update(with header: String?) {
        
        label.text = header
    }
}
