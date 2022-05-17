// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NFTsView: AnyObject {

    func update(with viewModel: NFTsViewModel)
}

final class NFTsViewController: BaseViewController {

    var presenter: NFTsPresenter!

    private var viewModel: NFTsViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavAndTabBarItem()
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

    // MARK: - Actions

    @IBAction func NFTsAction(_ sender: Any) {

    }
}

// MARK: - WalletsView

extension NFTsViewController: NFTsView {

    func update(with viewModel: NFTsViewModel) {
//        self.viewModel = viewModel
//        collectionView.reloadData()
//        if let idx = viewModel.selectedIdx(), !viewModel.items().isEmpty {
//            for i in 0..<viewModel.items().count {
//                collectionView.selectItem(
//                    at: IndexPath(item: i, section: 0),
//                    animated: idx == i,
//                    scrollPosition: .top
//                )
//            }
//        }
    }
}

// MARK: - UICollectionViewDataSource

extension NFTsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items().count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(KeyStoreCell.self, for: indexPath)
        cell.titleLabel.text = viewModel?.items()[indexPath.item].title
        return cell
    }
}

extension NFTsViewController: UICollectionViewDelegate {
    
}

extension NFTsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: Global.cellHeight)
    }
}

// MARK: - Configure UI

private extension NFTsViewController {
    
    func configureUI() {
        (view as? GradientView)?.colors = [
            Theme.color.background,
            Theme.color.backgroundDark
        ]
    }

    func configureNavAndTabBarItem() {
        title = Localized("nfts")
        tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(named: "tab_icon_nfts"),
            tag: 2
        )
    }
}
