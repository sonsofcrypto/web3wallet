// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol SettingsView: AnyObject {

    func update(with viewModel: SettingsViewModel)
}

class SettingsViewController: BaseViewController {

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.deselectAllExcept(viewModel?.selectedIdxPaths())

    }
}

// MARK: - WalletsView

extension SettingsViewController: SettingsView {

    func update(with viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
        collectionView.deselectAllExcept(viewModel.selectedIdxPaths())
    }
}

// MARK: - UICollectionViewDataSource

extension SettingsViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.sections[section].items.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel?.item(at: indexPath) else {
            fatalError("Missing viewModel \(indexPath)")
        }

        switch viewModel {
        case .selectableOption:
            return collectionView.dequeue(SettingsListSelectCell.self, for: indexPath)
                .update(with: viewModel)
        case .action:
            return collectionView.dequeue(SettingsActionCell.self, for: indexPath)
                .update(with: viewModel)
        default:
            return collectionView.dequeue(SettingsCell.self, for: indexPath)
                .update(with: viewModel)
        }
    }

}

extension SettingsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectItemAt(idxPath: indexPath))
    }
}

extension SettingsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: Global.cellHeightSmall)
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
