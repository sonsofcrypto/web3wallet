// Created by web3d3v on 13/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT


import UIKit

protocol ButtonsSheetViewDelegate: AnyObject {
    func buttonSheetView(_ bsv: ButtonsSheetView, didSelectButtonAt idx: Int)
    func buttonSheetView(_ bsv: ButtonsSheetView, didScroll cv: UICollectionView)
    func buttonSheetViewDidTapOpen(_ bsv: ButtonsSheetView)
    func buttonSheetViewDidTapClose(_ bsv: ButtonsSheetView)
}

class ButtonsSheetView: UIView {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundOverlay: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    weak var delegate: ButtonsSheetViewDelegate?
    
    private var viewModel: ButtonSheetViewModel?

    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    func openAction(_ sender: Any?) {
        delegate?.buttonSheetViewDidTapOpen(self)
    }
    
    func closeAction(_ sender: Any?) {
        delegate?.buttonSheetViewDidTapClose(self)
    }

    func update(with viewModel: ButtonSheetViewModel) {
        self.viewModel = viewModel
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension ButtonsSheetView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.buttons.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let button = viewModel?.buttons[indexPath.item]
        return collectionView.dequeue(ButtonsSheetViewCell.self, for: indexPath)
                .update(with: button)
    }
    
}

// MARK: - UICollectionViewDelegate

extension ButtonsSheetView: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("buttons sheet did select", indexPath)
        delegate?.buttonSheetView(self, didSelectButtonAt: indexPath.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.buttonSheetView(self, didScroll: collectionView)
    }
}

private extension ButtonsSheetView {

    func configureUI() {
        backgroundOverlay.backgroundColor = Theme.current.background.withAlpha(0.75)
    }

}