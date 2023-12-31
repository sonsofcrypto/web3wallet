// Created by web3d3v on 31/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class PrvKeyUpdateViewController: CollectionViewController {

    var presenter: PrvKeyUpdatePresenter!
    
    override func configureUI() {
        enableCardFlipTransitioning = true
        ctaButtonsCompactCnt = 3
        super.configureUI()
        presenter.present()
    }

    // MARK: - PrvKeyUpdateView

    override func present() {
        presenter.present()
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
        if isAccountsSection(indexPath) {
            return accountCell(indexPath, viewModel: viewModel)
        }
        switch viewModel {
        case let vm as CellViewModel.Text:
            return cv.dequeue(MnemonicUpdateCell.self, for: indexPath)
                .update(with: vm)
        case let vm as CellViewModel.TextInput:
            return cv.dequeue(TextInputCollectionViewCell.self, for: indexPath)
                .update(with: vm) { [weak self] t in
                    self?.setAccountName(t, indexPath)
                }
        case let vm as CellViewModel.Switch:
            return cv.dequeue(SwitchCollectionViewCell.self, for: indexPath)
                .update(with: vm) { [weak self] v in self?.backupDidChange(v) }
        case let vm as CellViewModel.Button:
            return cv.dequeue(ButtonCell.self, for: indexPath).update(with: vm)
        default:
            fatalError("[PrvKeyUpdateView] wrong cellForItemAt \(indexPath)")
        }
    }

    func accountCell(
        _ idxPath: IndexPath,
        viewModel: CellViewModel
    ) -> UICollectionViewCell {
        guard let vm = viewModel as? CellViewModel.KeyValueList else {
            fatalError("Not implemented")
        }
        let cell = cv.dequeue(MnemonicAccountCell.self, for: idxPath)
            .update(
                with: vm,
                nameHandler: { [weak self] t in self?.setAccountName(t, idxPath)},
                addressHandler: { [weak self] in self?.copyAddress(idxPath) },
                privKeyHandler: { [weak self] in self?.viewPrivKey(idxPath) }
            )
        cell.delegate = self
        return cell
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
            let footer = cv.dequeue(
                SectionFooterView.self,
                for: indexPath,
                kind: kind
            ).update(with: viewModel?.sections[safe: indexPath.section])
            if isAccountsSection(indexPath) {
                footer.label.adjustsFontSizeToFitWidth = true
                footer.label.textAlignment = .center
                footer.label.numberOfLines = 1
                footer.layoutMargins = .init(
                    top: 9, left: 20, bottom: 0, right: 20
                )
            }
            return footer
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    override func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        if isAccountsSection(IndexPath(item: 0, section: section)) {
            return String.estimateSize(
                "TEST",
                font: Theme.font.sectionFooter,
                maxWidth: cellSize.width,
                extraHeight: Theme.paddingHalf + 1
            )
        }
        return super.collectionView(
            collectionView,
            layout: collectionViewLayout,
            referenceSizeForFooterInSection: section
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = viewModel(at: indexPath) else { return cellSize }
        var height = cellSize.height
        switch viewModel {
        case _ as CellViewModel.Text:
            height = Constant.mnemonicCellHeight
        case let vm as CellViewModel.SwitchTextInput:
            height = vm.onOff ? Constant.cellSaltOpenHeight : cellSize.height
        case let vm as CellViewModel.SegmentWithTextAndSwitch:
            if vm.selectedSegment != 2 { height = Constant.cellOpenHeight }
        case let vm as CellViewModel.KeyValueList:
            height = cellSize.height * CGFloat(vm.items.count)
        default: ()
        }
        return .init(width: cellSize.width, height: height)
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let cell = cv.cellForItem(at: indexPath)
        if indexPath.isZero() {
            presenter.handleEvent(.CopyKey())
            (cell as? MnemonicUpdateCell)?.animateCopiedToPasteboard()
        }
        return false
    }

    // MARK: - Actions

    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handleEvent(.Dismiss())
    }

    func backupDidChange(_ onOff: Bool) {
        presenter.handleEvent(.SetICouldBackup(onOff: onOff))
    }

    func setAccountName(_ name: String, _ idxPath: IndexPath) {
        let ip = idxPath.section == 1 ? 0.int32 : offsetAccIdx(idxPath)
        presenter.handleEvent(.SetAccountName(name: name, idx: ip))
    }

    func setAccountHidden(_ hidden: Bool, _ idxPath: IndexPath) {
        presenter.handleEvent(
            .SetAccountHidden(hidden: hidden, idx: offsetAccIdx(idxPath))
        )
    }

    func copyAddress(_ idxPath: IndexPath) {
        presenter.handleEvent(.CopyAccountAddress(idx: offsetAccIdx(idxPath)))
    }

    func viewPrivKey(_ idxPath: IndexPath) {
        presenter.handleEvent(.ViewPrivKey(idx: offsetAccIdx(idxPath)))
    }

    @IBAction override func rightBarButtonAction(_ idx: Int) {
        presenter.handleEvent(.RightBarButtonAction(idx: idx.int32))
    }
    
    override func buttonSheetContainer(
        _ bsc: ButtonSheetContainer,
        didSelect idx: Int
    ) {
        presenter.handleEvent(.CTAAction(idx: idx.int32))
        let sectionCnt = cv.numberOfSections
        if idx == 0 && bsc.buttons.count > 1 && sectionCnt > 2 {
            let ip = IndexPath(item: 0, section: cv.numberOfSections - 1)
            cv.scrollToItem(at: ip, at: .centeredVertically, animated: true)
        }
    }

    override func alertAction(_ idx: Int, text: String?) {
        presenter.handleEvent(.AlertAction(idx: idx.int32, text: text))
    }

    // MARK: - SwipeCollectionViewCellDelegate

    override func rightSwipeActions(for idxPath: IndexPath) -> [SwipeAction]? {
        guard
            let vm = viewModel(at: idxPath) as? CellViewModel.KeyValueList,
            let hidden = vm.userInfo?["isHidden"] as? Bool
        else { return nil }

        let acc = SwipeAction(
            title: Localized(hidden ? "show" : "hide"),
            image: UIImage(systemName: hidden ? "eye" : "eye.slash"),
            handler: { [weak self] _, ip in self?.setAccountHidden(!hidden, ip)}
        )
        return [acc]
    }
}

// MARK: - Configure UI

private extension PrvKeyUpdateViewController {

    func isAccountsSection(_ idxPath: IndexPath) -> Bool {
        idxPath.section >= 2
    }

    func offsetAccIdx(_ idxPath: IndexPath) -> Int32 {
        (idxPath.section - 2).int32
    }
}

// MARK: - Constants

private extension PrvKeyUpdateViewController {
    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellOpenHeight: CGFloat = 138
    }
}
