// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicConfirmationViewController: CollectionViewController {
    @IBOutlet weak var ctaButton: OldButton!

    var presenter: MnemonicConfirmationPresenter!

    private var mnemonicInputViewModel: MnemonicInputViewModel?

    override func configureUI() {
        title = Localized("mnemonicConfirmation.title")
        ctaButtonsCompactCnt = 1
        super.configureUI()
        presenter.present()
    }

    override func present() {
        presenter.present()
    }

    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
        cv?.collectionViewLayout.invalidateLayout()
    }

    func update(
        with viewModel: CollectionViewModel.Screen,
        mnemonicInputViewModel: MnemonicInputViewModel
    ) {
        self.viewModel = viewModel
        self.mnemonicInputViewModel = mnemonicInputViewModel
        update(with: viewModel)
    }

    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel?.sections[safe: section]?.items.count ?? 0
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let viewModel = self.viewModel(at: indexPath) else {
            fatalError("Wrong number of items in section \(indexPath)")
        }
        switch viewModel {
        case _ as CellViewModel.Text:
            return cv.dequeue(MnemonicImportCell.self, for: indexPath)
                .update(with: mnemonicInputViewModel) { [weak self] str, loc in
                    self?.mnemonicDidChange(str, cursorLocation: loc)
                }
        case let vm as CellViewModel.TextInput:
            return cv.dequeue(TextInputCollectionViewCell.self, for: indexPath)
                .update(
                    with: vm,
                    inputHandler: { [weak self] t in self?.saltDidChange(t) }
                )
        default:
            ()
        }
        fatalError("Not implemented")
    }

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return cv.dequeue(SectionHeaderView.self, for: indexPath, kind: kind)
                    .update(with: viewModel?.sections[safe: indexPath.section])
        case UICollectionView.elementKindSectionFooter:
            return cv.dequeue(
                SectionFooterView.self,
                for: indexPath,
                kind: kind
            ).update(with: viewModel?.sections[safe: indexPath.section])
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }
    
    // MARK: - CTAs

    override func buttonSheetContainer(
        _ bsc: ButtonSheetContainer,
        didSelect idx: Int
    ) {
        presenter.handleEvent(.Confirm())
    }

    @IBAction override func rightBarButtonAction(_ idx: Int) {
        presenter.handleEvent(.Dismiss())
    }

    func mnemonicDidChange(_ mnemonic: String, cursorLocation: Int) {
        presenter.handleEvent(
            .MnemonicChanged(to: mnemonic, cursorLocation: cursorLocation.int32)
        )
    }

    func saltDidChange(_ salt: String) {
        presenter.handleEvent(.SaltChanged(to: salt))
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = viewModel(at: indexPath) else { return cellSize }
        switch viewModel {
        case _ as CellViewModel.Text:
            return CGSize(
                width: cellSize.width,
                height: Constant.mnemonicCellHeight
            )
        default:
            return cellSize
        }
    }
}

// MARK: - Constants

private extension MnemonicConfirmationViewController {

    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
    }
}
