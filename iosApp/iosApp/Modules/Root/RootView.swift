// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol RootView: AnyObject { }

final class RootViewController: EdgeCardsController, RootView {

    var presenter: RootPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.present()
    }
}
