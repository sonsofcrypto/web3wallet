// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicUpdateViewController: CollectionViewController {

    var presenter: MnemonicUpdatePresenter!

    override func configureUI() {
        title = Localized("mnemonic.title.update")
        cv.register(ButtonCell.self)
        enableCardFlipTransitioning = true
        super.configureUI()
        let layout = cv.collectionViewLayout as? TableFlowLayout
        layout?.hiddenSectionIdxs = buttonsSections().map { $0 }
        presenter.present()
    }

    // MARK: - MnemonicUpdateView

    override func update(with viewModel: CollectionViewModel.Screen) {
        super.update(with: viewModel)
        ctaButtonsContainer.setButtons(
            viewModel.ctaItems,
            compactCount: 1,
            sheetState: .auto,
            animated: true
        )
    }

    override func presentAlert(with viewModel: AlertViewModel) {
        let alertVc = AlertController(
            viewModel,
            handler: { [weak self] i, t in
                self?.presenter.handleEvent(.AlertAction(idx: i.int32, text: t))
            }
        )
        present(alertVc, animated: true)
    }

    override func keyboardWillHide(notification: Notification) {
        super.keyboardWillHide(notification: notification)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.presenter.present()
        }
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
            return cv.dequeue(ButtonCell.self, for: indexPath)
                .update(with: vm)
        default:
            fatalError("[MnemonicUpdateView] wrong cellForItemAt \(indexPath)")
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
        (cell as? SwipeCollectionViewCell)?.delegate = self
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
        guard let viewModel = viewModel(at: indexPath) else {return cellSize}
        switch viewModel {
        case _ as CellViewModel.Text:
            return CGSize(
                width: cellSize.width,
                height: Constant.mnemonicCellHeight
            )
        case _ as CellViewModel.Button:
            return CGSize(width: cellSize.width, height: Theme.buttonHeight)
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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        if section == buttonsSections().first {
            return .with(top: Theme.paddingHalf)
        } else if section == buttonsSections().last {
            return .with(bottom: Theme.padding)
        } else {
            return .zero
        }
    }

    // MARK: - UICollectionViewDelegate

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let cell = cv.cellForItem(at: indexPath)
        if indexPath.isZero() {
            presenter.handleEvent(.CopyMnemonic())
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

    func setAccountHidden(_ hidden: Bool, _ idxPath: IndexPath) {
        presenter.handleEvent(
            .SetAccountHidden(hidden: hidden, idx: offsetAccIdx(idxPath))
        )
    }

    func setAccountName(_ name: String, _ idxPath: IndexPath) {
        presenter.handleEvent(
            .SetAccountName(name: name, idx: offsetAccIdx(idxPath))
        )
    }

    func copyAddress(_ idxPath: IndexPath) {
        presenter.handleEvent(.CopyAccountAddress(idx: offsetAccIdx(idxPath)))
    }

    func viewPrivKey(_ idxPath: IndexPath) {
        presenter.handleEvent(.ViewPrivKey(idx: offsetAccIdx(idxPath)))
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
}

// MARK: - SwipeCollectionViewCellDelegate

extension MnemonicUpdateViewController: SwipeCollectionViewCellDelegate {

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

private extension MnemonicUpdateViewController {

    func isAccountsSection(_ idxPath: IndexPath) -> Bool {
        idxPath.section > (2 + buttonsSectionsCnt() - 1)
    }

    func isButtonSection(_ idxPath: IndexPath) -> Bool {
        buttonsSections().contains(idxPath.section)
    }

    func buttonsSections() -> Range<Int> {
        2..<(buttonsSectionsCnt() + 2)
    }

    func offsetAccIdx(_ idxPath: IndexPath) -> Int32 {
        (idxPath.section - (2 + buttonsSectionsCnt())).int32
    }

    func buttonsSectionsCnt() -> Int {
        let cnt = viewModel?.sections
            .filter { ($0.items.first as? CellViewModel.Button) != nil }
            .count ?? 0
        print("button sections count \(cnt)")
        return cnt
    }
}

// MARK: - Constants

private extension MnemonicUpdateViewController {
    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
    }
}
