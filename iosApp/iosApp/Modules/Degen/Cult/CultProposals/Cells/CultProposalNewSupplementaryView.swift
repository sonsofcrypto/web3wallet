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
        
        let label = UILabel()
        label.apply(style: .title3, weight: .bold)
        self.addSubview(label)
        self.label = label
        label.addConstraints(
            [
                .layout(
                    anchor: .trailingAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                ),
                .layout(
                    anchor: .topAnchor,
                    constant: .equalTo(constant: Theme.constant.padding)
                )
            ]
        )
        layoutConstraintBottom = bottomAnchor.constraint(
            equalTo: label.bottomAnchor
        )
        layoutConstraintBottom.isActive = true
        layoutConstraintLeading = label.leadingAnchor.constraint(
            equalTo: leadingAnchor,
            constant: Theme.constant.padding
        )
        layoutConstraintLeading.isActive = true
    }
}

extension CultProposalNewSupplementaryView {

    func update(with viewModel: CultProposalsViewModel.Section) {
        
        label.text = viewModel.title
        
        layoutConstraintLeading.constant = viewModel.horizontalScrolling ?
        Theme.constant.padding :
        Theme.constant.padding + Theme.constant.padding.half
        
        layoutConstraintBottom.constant = viewModel.horizontalScrolling ?
        0 :
        Theme.constant.padding.half
    }
}
