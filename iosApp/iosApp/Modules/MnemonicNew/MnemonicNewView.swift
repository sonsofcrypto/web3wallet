// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicNewViewController: CollectionViewController {

    var presenter: MnemonicNewPresenter!

    override func configureUI() {
        title = Localized("mnemonic.title.new")
        enableCardFlipTransitioning = true
        super.configureUI()
        presenter.present()
    }

    // MARK: - MnemonicView

    override func presentAlert(with viewModel: AlertViewModel) {
        let alertVc = AlertController(
            viewModel,
            handler: { [weak self] idx, t in self?.alertAction(idx, text: t) }
        )
        present(alertVc, animated: true)
    }

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
            let cell = accountCell(indexPath, viewModel: viewModel)
            (cell as? SwipeCollectionViewCell)?.delegate = self
            return cell
        }
        switch viewModel {
        case let vm as CellViewModel.Text:
            return cv.dequeue(MnemonicNewCell.self, for: indexPath)
                .update(with: vm)
        case let vm as CellViewModel.TextInput:
            return cv.dequeue(TextInputCollectionViewCell.self, for: indexPath)
                .update(with: vm) { [weak self] t in self?.nameDidChange(t) }
        case let vm as CellViewModel.Switch:
            return cv.dequeue(SwitchCollectionViewCell.self, for: indexPath)
                .update(with: vm) { [weak self] v in self?.backupDidChange(v) }
        case let vm as CellViewModel.SwitchTextInput:
            return cv.dequeue(
                SwitchTextInputCollectionViewCell.self,
                for: indexPath
            ).update(
                with: vm,
                switchHandler: { [weak self] v in self?.saltSwitchDidChange(v)},
                inputHandler: { [weak self] t in self?.saltTextDidChange(t)},
                learnMoreHandler: { [weak self] in self?.saltLearnAction()}
            )
        case let vm as CellViewModel.SegmentWithTextAndSwitch:
            return collectionView.dequeue(
                SegmentWithTextAndSwitchCell.self,
                for: indexPath
            ).update(
                with: vm,
                segmentHandler: { [weak self] i in self?.passTypeDidChange(i)},
                textHandler: { [weak self] t in self?.passwordDidChange(t)},
                switchHandler: { [weak self] v in self?.allowFaceIdDidChange(v)}
            )
        case let vm as CellViewModel.SegmentSelection:
            return cv.dequeue(SegmentSelectionCell.self, for: indexPath)
                .update(with: vm) { [weak self] i in self?.entropySizeChange(i)}
        default:
            ()
        }
        fatalError("Not implemented")
    }
    
    func accountCell(
        _ idxPath: IndexPath,
        viewModel: CellViewModel
    ) -> UICollectionViewCell {
        guard let vm = viewModel as? CellViewModel.KeyValueList else {
            fatalError("Not implemented")
        }
        return cv.dequeue(MnemonicAccountCell.self, for: idxPath)
            .update(
                with: vm,
                nameHandler: { [weak self] t in self?.setAccountName(t, idxPath)},
                addressHandler: { [weak self] in self?.copyAddress(idxPath) },
                privKeyHandler: { [weak self] in self?.viewPrivKey(idxPath) }
            )
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

    // MARK: - UICollectionViewDelegate

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let cell = cv.cellForItem(at: indexPath)
        if indexPath.isZero() {
            presenter.handleEvent(.CopyMnemonic())
            (cell as? MnemonicNewCell)?.animateCopiedToPasteboard()
        }
        return false
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        guard let viewModel = viewModel(at: indexPath) else {return cellSize}
        switch viewModel {
        case _ as CellViewModel.Text:
            return CGSize(
                width: cellSize.width,
                height: Constant.mnemonicCellHeight
            )
        case let vm as CellViewModel.SwitchTextInput:
            return CGSize(
                width: cellSize.width,
                height: vm.onOff
                    ? Constant.cellSaltOpenHeight
                    : cellSize.height
            )
        case let vm as CellViewModel.SegmentWithTextAndSwitch:
            return CGSize(
                width: cellSize.width,
                height: vm.selectedSegment != 2
                    ? Constant.cellPassOpenHeight
                    : cellSize.height
            )
        case let vm as CellViewModel.KeyValueList:
            return CGSize(
                width: cellSize.width,
                height: cellSize.height * CGFloat(vm.items.count)
            )
        default:
            return cellSize
        }
    }

    // MARK: - Actions

    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handleEvent(MnemonicNewPresenterEvent.Dismiss())
    }

    func nameDidChange(_ name: String) {
        presenter.handleEvent(.SetName(name: name))
    }

    func backupDidChange(_ onOff: Bool) {
        presenter.handleEvent(.SetICouldBackup(onOff: onOff))
    }

    func saltSwitchDidChange(_ onOff: Bool) {
        presenter.handleEvent(.SaltSwitch(onOff: onOff))
    }

    func saltTextDidChange(_ text: String) {
        presenter.handleEvent(.SetSalt(salt: text))
    }

    func saltLearnAction() {
        presenter.handleEvent(.SaltLearnMore())
    }

    func passTypeDidChange(_ idx: Int) {
        presenter.handleEvent(.SetPassType(idx: idx.int32))
    }

    func passwordDidChange(_ text: String) {
        presenter.handleEvent(.SetPassword(text: text))
    }

    func allowFaceIdDidChange(_ onOff: Bool) {
        presenter.handleEvent(.SetAllowFaceId(onOff: onOff))
    }

    func entropySizeChange(_ idx: Int) {
        presenter.handleEvent(.SetEntropySize(idx: idx.int32))
    }

    func setAccountName(_ name: String, _ idxPath: IndexPath) {
        presenter.handleEvent(
            .SetAccountName(name: name, idx: idxPath.section.int32 - 2)
        )
    }

    func setAccountHidden(_ hidden: Bool, _ idxPath: IndexPath) {
        presenter.handleEvent(
            .SetAccountHidden(hidden: hidden, idx: idxPath.section.int32 - 2)
        )
    }

    func copyAddress(_ idxPath: IndexPath) {
        presenter.handleEvent(
            .CopyAccountAddress(idx: idxPath.section.int32 - 2)
        )
    }

    func viewPrivKey(_ idxPath: IndexPath) {
        presenter.handleEvent(.ViewPrivKey(idx: idxPath.section.int32 - 2))
    }

    @IBAction override func rightBarButtonAction(_ sender: Any?) {
        guard let sender = sender as? UIBarButtonItem else { return }
        presenter.handleEvent(.RightBarButtonAction(idx: sender.tag.int32))
    }

    override func buttonSheetContainer(
        _ bsc: ButtonSheetContainer,
        didSelect idx: Int
    ) {
        presenter.handleEvent(.CTAAction(idx: idx.int32))
        let sectionCnt = cv.numberOfSections
        if idx == 0 && ctaButtonsContainer.buttons.count > 1 && sectionCnt > 2 {
            let ip = IndexPath(item: 0, section: cv.numberOfSections - 1)
            cv.scrollToItem(at: ip, at: .centeredVertically, animated: true)
        }
    }

    override func alertAction(_ idx: Int, text: String?) {
        presenter.handleEvent(.AlertAction(idx: idx.int32, text: text))
    }
}

// MARK: - SwipeCollectionViewCellDelegate

extension MnemonicNewViewController: SwipeCollectionViewCellDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        editActionsForItemAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> [SwipeAction]? {
        guard
            orientation == .right,
            let vm = viewModel(at: indexPath) as? CellViewModel.KeyValueList,
            let isHidden = vm.userInfo?["isHidden"] as? Bool
        else { return nil }

        let flag = SwipeAction(
            style: .default,
            title: Localized(isHidden ? "show" : "hide"),
            handler: { [weak self] act, idxPath in
                self?.setAccountHidden(!isHidden, indexPath)
            }
        )
        flag.image = UIImage(systemName: isHidden ? "eye" : "eye.slash")
        flag.hidesWhenSelected = true
        return [flag]
    }

    func collectionView(
        _ collectionView: UICollectionView,
        editActionsOptionsForItemAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation
    ) -> SwipeOptions {
        cellSwipeOption
    }
}

// MARK: - Configure UI

private extension MnemonicNewViewController {

    func isAccountsSection(_ idxPath: IndexPath) -> Bool {
        idxPath.section > 1
    }
}

// MARK: - Constants

private extension MnemonicNewViewController {

    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
    }
}
