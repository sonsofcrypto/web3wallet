// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol NewMnemonicView: AnyObject {

    func update(with viewModel: NewMnemonicViewModel)
}

class NewMnemonicViewController: UIViewController {

    var presenter: NewMnemonicPresenter!

    private var viewModel: NewMnemonicViewModel?
    
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

// MARK: - NewMnemonic

extension NewMnemonicViewController: NewMnemonicView {

    func update(with viewModel: NewMnemonicViewModel) {
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

extension NewMnemonicViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.items().count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(NewMnemonicCell.self, for: indexPath)
        cell.titleLabel.text = viewModel?.items()[indexPath.item].title
        return cell
    }
}

extension NewMnemonicViewController: UICollectionViewDelegate {
    
}

extension NewMnemonicViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width - 32, height: Global.cellHeight)
    }
}

// MARK: - Configure UI

extension NewMnemonicViewController {
    
    func configureUI() {
        title = Localized("wallets")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }
}
