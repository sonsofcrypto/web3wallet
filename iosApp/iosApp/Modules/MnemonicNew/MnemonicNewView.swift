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

    func update(with viewModel: CollectionViewModel.Screen) {
        let prevViewModel = self.viewModel
        self.viewModel = viewModel

        guard let cv = collectionView else { return }

        cv.reloadAnimatedIfNeeded(
            prevVM: prevViewModel,
            currVM: viewModel,
            reloadOnly: !didAppear
        )

        setCTAButtons(
            buttons: [
                .init(title: viewModel.ctaItems.first ?? "", style: .secondary),
                .init(title: viewModel.ctaItems.last ?? "", style: .primary),
            ]
        )
    }

    // MARK: - Actions

    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handleEvent(MnemonicNewPresenterEvent.Dismiss())
    }

    override func buttonContainer(
        _ buttonContainer: ButtonContainer,
        didSelectButtonAt idx: Int
    ) {
        switch idx {
        case 0:
            presenter.handleEvent(.AddAccount())
            cv.scrollToItem(
                at: cv.lastIdxPath(),
                at: .centeredVertically,
                animated: true
            )
        case 1: presenter.handleEvent(.CreateMnemonic())
        default: ()
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
            return cv.dequeue(MnemonicNewCell.self, for: indexPath)
                .update(with: vm)
        case let vm as CellViewModel.TextInput:
            return cv.dequeue(TextInputCollectionViewCell.self, for: indexPath)
                .update(
                    with: vm,
                    inputHandler: { [weak self] t in self?.nameDidChange(t) }
                )
        case let vm as CellViewModel.Switch:
            return cv.dequeue(SwitchCollectionViewCell.self, for: indexPath)
                .update(
                    with: vm,
                    handler: { [weak self] v in self?.iCloudBackupDidChange(v) }
                )
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
        default:
            ()
        }
        fatalError("Not implemented")
    }
    
    func accountCell(
        _ idxPath: IndexPath,
        viewModel: CellViewModel
    ) -> UICollectionViewCell {
        switch viewModel {
        case let vm as CellViewModel.TextInput:
            return cv.dequeue(TextInputCollectionViewCell.self, for: idxPath)
                .update(
                    with: vm,
                    inputHandler: { [weak self] name in
                        self?.changeAccountName(name, idxPath: idxPath)
                    }
                )
        case let vm as CellViewModel.Label:
            return cv.dequeue(LabelCell.self, for: idxPath).update(with: vm)
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
            return cv.dequeue(SectionFooterView.self, for: indexPath, kind: kind)
                .update(with: viewModel?.sections[safe: indexPath.section])
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension MnemonicNewViewController {

    override func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        let cell = cv.cellForItem(at: indexPath)
        if indexPath.isZero() {
            presenter.handleEvent(.CopyMnemonic())
            (cell as? MnemonicNewCell)?.animateCopiedToPasteboard()
        }
        guard isAccountsSection(indexPath) else { return false }
        (cell as? LabelCell)?.animateCopy()
        presenter.handleEvent(
            .CopyAccountAddress(idx: indexPath.section.int32 - 2)
        )
        return false
    }

    func nameDidChange(_ name: String) {
        presenter.handleEvent(.SetName(name: name))
    }

    func iCloudBackupDidChange(_ onOff: Bool) {
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
    
    func changeAccountName(_ name: String, idxPath: IndexPath) {
        presenter.handleEvent(
            .SetAccountName(name: name, idx: idxPath.section.int32 - 2)
        )
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
        default:
            return cellSize
        }
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
