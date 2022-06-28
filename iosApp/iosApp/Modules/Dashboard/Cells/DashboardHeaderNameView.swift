// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderNameView: UICollectionReusableView {
    
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

private extension DashboardHeaderNameView {
    
    func configureUI() {
        
        let label = UILabel()
        label.font = Theme.font.title2
        label.textColor = Theme.colour.labelPrimary
        self.label = label
        addSubview(label)
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding * 0.5)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: Theme.constant.padding)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 30))
            ]
        )
        
        let view = UIView()
        view.backgroundColor = Theme.colour.labelPrimary
        addSubview(view)
        view.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: Theme.constant.padding * 0.5)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: -Theme.constant.padding)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 0.3)),
                .layout(anchor: .bottomAnchor)
            ]
        )
    }
}

extension DashboardHeaderNameView {

    func update(with viewModel: DashboardViewModel.Section) {
        
        label.text = viewModel.name.uppercased()
    }
}
