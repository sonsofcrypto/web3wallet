// Created by web3d4v on 06/07/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol TokenSendView: AnyObject {

    func update(with viewModel: TokenSendViewModel)
}

final class TokenSendViewController: BaseViewController {

    var presenter: TokenSendPresenter!

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var viewModel: TokenSendViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter?.present()
    }
}

extension TokenSendViewController: TokenSendView {

    func update(with viewModel: TokenSendViewModel) {

        self.viewModel = viewModel
    }
}

private extension TokenSendViewController {
    
    func configureNavigationBar() {
        
        title = viewModel?.title
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(navBarLeftActionTapped)
        )        
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
}
