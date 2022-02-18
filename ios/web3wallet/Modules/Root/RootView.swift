// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol RootView: AnyObject {

}

class RootViewController: UIViewController {

    var presenter: RootPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func RootAction(_ sender: Any) {

    }
}

// MARK: - WalletsView

extension RootViewController: RootView {

}

// MARK: - Configure UI

extension RootViewController {
    
    func configureUI() {
        title = Localized("wallets")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }
}
