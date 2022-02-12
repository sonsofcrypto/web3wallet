// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol MnemonicsView: AnyObject {

    func update(with viewModel: MnemonicsViewModel)
}

class MnemonicsViewController: UIViewController {

    var presenter: MnemonicsPresenter!

    private var viewModel: MnemonicsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.present()
    }
}

// MARK: - MnemonicsView

extension MnemonicsViewController: MnemonicsView {

    func update(with viewModel: MnemonicsViewModel) {

    }
}
