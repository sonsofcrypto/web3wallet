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
    @IBOutlet weak var buttonsSheetView: ButtonsSheetView!
    
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
}

// MARK: - KeyStoreView

extension KeyStoreViewController: KeyStoreView {

    func update(with viewModel: KeyStoreViewModel) {
        self.viewModel = viewModel
        buttonsSheetView.update(with: viewModel.buttons)
        collectionView.reloadData()
        logoContainer.isHidden = !viewModel.isEmpty
        if let idx = viewModel.selectedIdx, !viewModel.items.isEmpty {
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
        return viewModel?.items.count ?? 0
    }
    

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(KeyStoreCell.self, for: indexPath)
        cell.titleLabel.text = viewModel?.items[indexPath.item].title
        return cell
    }
}

extension KeyStoreViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.handle(.didSelectKeyStoreItemtAt(idx: indexPath.item))
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

// MARK: - ButtonsSheetViewDelegate

extension KeyStoreViewController: ButtonsSheetViewDelegate {

    func buttonSheetView(_ bsv: ButtonsSheetView, didSelectButtonAt idx: Int) {
        presenter.handle(.didSelectButtonAt(idx: idx))
    }

    func buttonSheetViewDidTapOpen(_ bsv: ButtonsSheetView) {
        presenter.handle(.didChangeButtonsState(open: true))
    }

    func buttonSheetView(_ bsv: ButtonsSheetView, didScroll cv: UICollectionView) {
        //
    }

    func buttonSheetViewDidTapClose(_ bsv: ButtonsSheetView) {
        presenter.handle(.didChangeButtonsState(open: false))
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
