// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol RootView: AnyObject {

}

final class RootViewController: EdgeCardsController {

    var presenter: RootPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

// MARK: - WalletsView

extension RootViewController: RootView {

}

// MARK: - Configure UI

extension RootViewController {
    
    func configureUI() {
//        (view as? GradientView)?.colors = [
//            Theme.colour.backgroundBaseSecondary,
//            Theme.colour.backgroundBasePrimary
//        ]
    }
}
