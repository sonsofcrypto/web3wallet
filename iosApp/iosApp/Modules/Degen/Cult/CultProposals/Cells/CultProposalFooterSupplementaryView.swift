// Created by web3d4v on 27/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class CultProposalFooterSupplementaryView: UICollectionReusableView {
    
    private weak var imageView: UIImageView!
    private weak var label: UILabel!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        
        let imageView = UIImageView()
        imageView.addConstraints(
            [
                .layout(
                    anchor: .widthAnchor,
                    constant: .equalTo(
                        constant: frame.width * 0.4
                    )
                ),
                .layout(
                    anchor: .heightAnchor,
                    constant: .equalTo(
                        constant: frame.width * 0.4
                    )
                )
            ]
        )
        imageView.contentMode = .scaleAspectFit
        self.imageView = imageView
        
        let label = UILabel()
        label.apply(style: .title3, weight: .bold)
        label.textAlignment = .center
        self.label = label

        let hStack = VStackView([imageView, label])
        addSubview(hStack)
        hStack.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .topAnchor),
                .layout(
                    anchor: .bottomAnchor,
                    constant: .equalTo(constant: Theme.constant.padding * 1.5)
                )
            ]
        )
    }
}

extension CultProposalFooterSupplementaryView {

    func update(with viewModel: CultProposalsViewModel.Section.Footer) {
        
        imageView.image = viewModel.imageName.assetImage
        label.text = viewModel.text
    }
}
