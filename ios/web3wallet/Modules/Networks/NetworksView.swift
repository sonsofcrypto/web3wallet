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
    private var prevViewSize: CGSize = .zero

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
        prevViewSize = view.bounds.size
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.bounds.size != prevViewSize {
            collectionView.collectionViewLayout.invalidateLayout()
            prevViewSize = view.bounds.size
        }
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
            collectionView.deselectAllExcept(
                IndexPath(item: idx, section: 0),
                animated: true
            )
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectNetwork(idx: indexPath.item))
    }
}

extension NetworksViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: Constant.cellHeight
        )
    }
}

// MARK: - Configure UI

extension NetworksViewController {
    
    func configureUI() {
        title = Localized("networks")
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
