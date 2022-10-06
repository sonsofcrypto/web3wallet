// Created by web3d4v on 28/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class EmbeddedErrorCollectionViewCell: UICollectionViewCell {
    
    struct ViewModel {
        
        let title: String
        let imageName: String
        let message: String
        let button: String
    }
    
    struct Handler {
        
        let onRetryTapped: () -> Void
    }

    private weak var title: UILabel!
    private weak var imageView: UIImageView!
    private weak var message: UILabel!
    private weak var button: UIButton!
    
    private var handler: Handler!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        let title = UILabel()
        title.apply(style: .title3)
        self.title = title
        
        let wrapperView = UIView()
        wrapperView.backgroundColor = .clear
        let imageView = UIImageView()
        imageView.addConstraints(
            [
                .layout(anchor: .widthAnchor, constant: .equalTo(constant: 150)),
                .layout(anchor: .heightAnchor, constant: .equalTo(constant: 150)),
                .layout(anchor: .topAnchor),
                .layout(anchor: .bottomAnchor),
                .layout(anchor: .centerXAnchor)
            ]
        )
        wrapperView.addSubview(imageView)
        self.imageView = imageView
        
        let message = UILabel()
        message.apply(style: .body)
        self.message = message
        
        let button = Button()
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        button.style = .primary
        self.button = button
        
        let vStack = VStackView([wrapperView, title, message, button])
        vStack.layer.cornerRadius = Theme.constant.cornerRadius
        vStack.backgroundColor = Theme.colour.cellBackground
        addSubview(vStack)
        
        vStack.addConstraints(
            .toEdges(padding: Theme.constant.padding)
        )
    }
}

extension EmbeddedErrorCollectionViewCell {
    
    func update(
        with viewModel: ViewModel,
        handler: Handler
    ) {
        
        self.handler = handler
        
        title.text = viewModel.title
        message.text = viewModel.title
        imageView.image = UIImage.loadImage(named: viewModel.imageName)
        button.setTitle(viewModel.button, for: .normal)
    }
}

private extension EmbeddedErrorCollectionViewCell {
    
    @objc func retryTapped() {
        
        handler.onRetryTapped()
    }
}
