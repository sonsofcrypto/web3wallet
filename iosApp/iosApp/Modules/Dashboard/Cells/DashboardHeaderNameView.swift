// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardHeaderNameView: UICollectionReusableView, ThemeProviding {
    
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
        label.font = theme.font(for: .title2)
        label.textColor = theme.colour(for: .text)
        self.label = label
        addSubview(label)
        label.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: theme.padding * 0.5)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: theme.padding)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 30))
            ]
        )
        
        let view = UIView()
        view.backgroundColor = theme.colour(for: .text)
        addSubview(view)
        view.addConstraints(
            [
                .layout(anchor: .leadingAnchor, constant: .equalTo(constant: theme.padding * 0.5)),
                .layout(anchor: .trailingAnchor, constant: .equalTo(constant: -theme.padding)),
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
