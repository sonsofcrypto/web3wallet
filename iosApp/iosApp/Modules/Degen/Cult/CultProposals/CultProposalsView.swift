// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol CultProposalsView: AnyObject {

    func update(with viewModel: CultProposalsViewModel)
}

class CultProposalsViewController: UIViewController {

    var presenter: CultProposalsPresenter!

    private var viewModel: CultProposalsViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    // MARK: - Actions
}

// MARK: - WalletsView

extension CultProposalsViewController: CultProposalsView {

    func update(with viewModel: CultProposalsViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
        if let idx = viewModel.selectedIdx(), !viewModel.items().isEmpty {
            for i in 0..<viewModel.items().count {
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

extension CultProposalsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items().count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CultProposalCell.self, for: indexPath)
        let viewModel = viewModel?.items()[indexPath.item]
        cell.update(with: viewModel)
        return cell
    }
}

extension CultProposalsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectItemAt(idx: indexPath.item))
    }
}

extension CultProposalsViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: 173)
    }
}

// MARK: - Configure UI

extension CultProposalsViewController {
    
    func configureUI() {
        title = Localized("Proposals")
    }
}
