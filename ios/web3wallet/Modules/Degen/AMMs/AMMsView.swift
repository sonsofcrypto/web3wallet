// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol AMMsView: AnyObject {

    func update(with viewModel: AMMsViewModel)
}

class AMMsViewController: UIViewController {

    var presenter: AMMsPresenter!

    private var viewModel: AMMsViewModel?
    private var cellSize: CGSize = .zero
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let length = (view.bounds.width - Global.padding * 2 - Constant.spacing) / 2
        cellSize = CGSize(width: length, height: length)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        collectionView.indexPathsForSelectedItems?.forEach {
            collectionView.deselectItem(at: $0, animated: true)
        }
    }
}

// MARK: - WalletsView

extension AMMsViewController: AMMsView {

    func update(with viewModel: AMMsViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension AMMsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.dapps.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AMMsCell.self, for: indexPath)
        cell.update(with: viewModel?.dapps[indexPath.item])
        return cell
    }
}

extension AMMsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cellSize
    }
}

extension AMMsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectDApp(idx: indexPath.item))
    }
}

// MARK: - Configure UI

extension AMMsViewController {
    
    func configureUI() {
        title = Localized("amms")
        (view as? GradientView)?.colors = [
            ThemeOld.current.background,
            ThemeOld.current.backgroundDark
        ]

        var insets = collectionView.contentInset
        insets.top += Global.padding
        insets.bottom += Global.padding
        collectionView.contentInset = insets
    }
}

// MARK: - Constant

extension AMMsViewController {

    enum Constant {
        static let spacing: CGFloat = 17
    }
}
