// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SwapView: AnyObject {

    func update(with viewModel: SwapViewModel)
}

class SwapViewController: UIViewController {

    var presenter: SwapPresenter!

    private var viewModel: SwapViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func SwapAction(_ sender: Any) {

    }
}

// MARK: - WalletsView

extension SwapViewController: SwapView {

    func update(with viewModel: SwapViewModel) {
        self.viewModel = viewModel
        self.title = viewModel.title
    }
}

// MARK: - Configure UI

extension SwapViewController {
    
    func configureUI() {
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }
}
