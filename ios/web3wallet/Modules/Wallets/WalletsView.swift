// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol WalletsView: AnyObject {

    func update(with viewModel: WalletsViewModel)
}

class WalletsViewController: UIViewController {

    var presenter: WalletsPresenter!

    private var viewModel: WalletsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        (view as? GradientView)?.colors = [
            UIColor(named: "gbGradientTop"),
            UIColor(named: "gbGradientBottom")
        ].compactMap { $0 }
        
        presenter?.present()
    }
}

// MARK: - WalletsView

extension WalletsViewController: WalletsView {

    func update(with viewModel: WalletsViewModel) {

    }
}

// MARK: - Configure UI

extension WalletsViewController {
    
    func configureUI() {
        (view as? GradientView)?.colors = [
            UIColor(named: "gbGradientTop"),
            UIColor(named: "gbGradientBottom")
        ].compactMap { $0 }
    }
}
