// Created by web3d4v on 18/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class DeleteCell: ThemeCell {
    @IBOutlet weak var button: OldButton!

    typealias Handler = () -> Void

    private var handler: Handler?

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
}

extension DeleteCell {

    func update(with title: String, handler: Handler?) -> Self {
        self.handler = handler
        button.setTitle(title, for: .normal)
        return self
    }

    func update(with viewModel: CellViewModel.Button, handler: Handler?) -> Self {
        return update(with: viewModel.button.title, handler: handler)
    }
}

private extension DeleteCell {
    
    func configureUI() {
        let button = OldButton(type: .custom)
        button.style = .primary(action: .destructive)
        button.addTar(self, action: #selector(buttonAction))
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
    
    @objc func buttonAction() { handler?() }
}
