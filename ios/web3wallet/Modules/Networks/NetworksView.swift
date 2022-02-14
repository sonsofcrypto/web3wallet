// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NetworksView: AnyObject {

    func update(with viewModel: NetworksViewModel)
}

class NetworksViewController: UIViewController {

    var presenter: NetworksPresenter!

    private var viewModel: NetworksViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions

    @IBAction func templateAction(_ sender: Any) {

    }
}

// MARK: - WalletsView

extension NetworksViewController: NetworksView {

    func update(with viewModel: NetworksViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
        if let idx = viewModel.selectedIdx(), !viewModel.network().isEmpty {
            for i in 0..<viewModel.network().count {
                collectionView.selectItem(
                    at: IndexPath(item: i, section: 0),
                    animated: idx == i,
                    scrollPosition: .top
                )
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension NetworksViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.network().count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(NetworksCell.self, for: indexPath)
        cell.update(with: viewModel?.network()[indexPath.item])
        return cell
    }
}

extension NetworksViewController: UICollectionViewDelegate {
    
}

extension NetworksViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: Constant.cellHeight)
    }
}

// MARK: - Configure UI

extension NetworksViewController {
    
    func configureUI() {
        title = Localized("wallets")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }
}

// MARK: - Constants

extension NetworksViewController {

    enum Constant {
        static let cellHeight: CGFloat = 115
    }
}