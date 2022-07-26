// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsView: AnyObject {

    func update(with viewModel: SettingsViewModel)
}

final class SettingsViewController: BaseViewController {

    var presenter: SettingsPresenter!

    @IBOutlet weak var collectionView: UICollectionView!

    private var viewModel: SettingsViewModel!

    override func viewDidLoad() {

        super.viewDidLoad()
        
        presenter.present()
    }
}

extension SettingsViewController {
    
    @objc func dismissAction() {
        
        presenter.handle(.dismiss)
    }
}

extension SettingsViewController: SettingsView {

    func update(with viewModel: SettingsViewModel) {
        
        self.viewModel = viewModel
        
        title = viewModel.title
        
        if (navigationController?.viewControllers.count ?? 0) > 1 {
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: .init(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(dismissAction)
            )
        }
        
        collectionView.reloadData()
    }
}

extension SettingsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        viewModel.sections.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        viewModel.sections[section].items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        collectionView.dequeue(
            SettingsCell.self,
            for: indexPath
        ).update(
            with: viewModel.item(at: indexPath)
        )
    }
}

extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        
        let item = viewModel.item(at: indexPath)
        presenter.handle(.didSelect(setting: item.setting))
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        .init(
            width: collectionView.frame.width - Theme.constant.padding * 2,
            height: Theme.constant.cellHeightSmall
        )
    }
}
