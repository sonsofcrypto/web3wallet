// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsView: AnyObject {

    func update(with viewModel: SettingsViewModel)
}

class SettingsViewController: UIViewController {

    var presenter: SettingsPresenter!

    private var viewModel: SettingsViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureNavAndTabBarItem()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }
}

// MARK: - WalletsView

extension SettingsViewController: SettingsView {

    func update(with viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension SettingsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items.count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeue(SettingsCell.self, for: indexPath)
            .update(with: viewModel?.items[indexPath.item])
    }
}

extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectItemAt(idx: indexPath.item))
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: Global.cellHeight)
    }
}

// MARK: - Configure UI

private extension SettingsViewController {
    
    func configureUI() {
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }

    func configureNavAndTabBarItem() {
        title = Localized("settings")
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "tab_icon_settings"),
            tag: 4
        )
    }
}
