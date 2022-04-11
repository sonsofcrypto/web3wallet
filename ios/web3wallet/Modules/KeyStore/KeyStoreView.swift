// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol KeyStoreView: AnyObject {

    func update(with viewModel: KeyStoreViewModel)
}

class KeyStoreViewController: UIViewController {

    var presenter: KeyStorePresenter!

    private var viewModel: KeyStoreViewModel?
    private var prevViewSize: CGSize = .zero

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Actions

    @IBAction func createNewWalletAction(_ sender: Any) {
        presenter.handle(.newMnemonic)
    }
    
    @IBAction func importWalletAction(_ sender: Any) {
        presenter.handle(.importMnemonic)
    }
    
    @IBAction func connectHDWalletAction(_ sender: Any) {
        presenter.handle(.connectHardwareWallet)
    }
}

// MARK: - KeyStoreView

extension KeyStoreViewController: KeyStoreView {

    func update(with viewModel: KeyStoreViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
        logoContainer.isHidden = !viewModel.isEmpty()
        if let idx = viewModel.selectedIdx(), !viewModel.wallets().isEmpty {
            collectionView.deselectAllExcept(
                IndexPath(item: idx, section: 0),
                animated: true
            )
        }
    }
}

// MARK: - UICollectionViewDataSource

extension KeyStoreViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.wallets().count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(KeyStoreCell.self, for: indexPath)
        cell.titleLabel.text = viewModel?.wallets()[indexPath.item].title
        return cell
    }
}

extension KeyStoreViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectWalletAt(idx: indexPath.item))
    }
}

extension KeyStoreViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(
            width: view.bounds.width - Global.padding * 2,
            height: Global.cellHeight
        )
    }
}

// MARK: - Configure UI

extension KeyStoreViewController {
    
    func configureUI() {
        title = Localized("wallets")
        (view as? GradientView)?.colors = [
            Theme.current.background,
            Theme.current.backgroundDark
        ]
    }
}
