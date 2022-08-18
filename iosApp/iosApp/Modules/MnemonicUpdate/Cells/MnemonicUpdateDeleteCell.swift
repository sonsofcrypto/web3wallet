// Created by web3d4v on 18/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class MnemonicUpdateDeleteCell: UICollectionViewCell {

    @IBOutlet weak var button: Button!

    struct Handler {
        
        let onDelete: () -> Void
    }
    
    private var handler: Handler!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        configureUI()
    }
}

extension MnemonicUpdateDeleteCell {

    func update(
        with title: String,
        handler: Handler
    ) -> Self {
        
        self.handler = handler
        
        button.setTitle(title, for: .normal)
        
        return self
    }
}

private extension MnemonicUpdateDeleteCell {
    
    func configureUI() {
        
        let button = Button(type: .custom)
        button.style = .primary
        button.backgroundColor = Theme.colour.destructive
        button.addTarget(self, action: #selector(onDeleteTapped), for: .touchUpInside)
        self.button = button
        addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [
                leadingAnchor.constraint(equalTo: button.leadingAnchor),
                trailingAnchor.constraint(equalTo: button.trailingAnchor),
                centerYAnchor.constraint(equalTo: button.centerYAnchor)
            ]
        )
    }
    
    @objc func onDeleteTapped() {
        
        handler.onDelete()
    }
}
