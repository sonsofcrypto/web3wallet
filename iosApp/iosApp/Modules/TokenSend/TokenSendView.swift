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
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var disclaimerLabel: UILabel!
    
    private var viewModel: TokenSendViewModel?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        presenter?.present()
    }
    
}

extension TokenSendViewController: TokenSendView {

    func update(with viewModel: TokenSendViewModel) {

        self.viewModel = viewModel
        
        configureNavigationBar()
        
        switch viewModel.content {
            
        case let .loaded(item):
            nameLabel.text = item.name
            addressLabel.text = item.address
            disclaimerLabel.text = item.disclaimer
            
        case .loading, .error:
            break
        }
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
        
        cardView.backgroundColor = Theme.colour.backgroundBasePrimary
        cardView.layer.cornerRadius = Theme.constant.cornerRadius
        
        nameLabel.font = Theme.font.body
        nameLabel.textColor = Theme.colour.labelPrimary
        
        addressLabel.font = Theme.font.body
        addressLabel.textColor = Theme.colour.labelPrimary
        addressLabel.textAlignment = .center

        disclaimerLabel.font = Theme.font.body
        disclaimerLabel.textColor = Theme.colour.labelPrimary
    }
    
    @objc func navBarLeftActionTapped() {
        
        presenter.handle(.dismiss)
    }
}
