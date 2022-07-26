// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol MnemonicImportView: AnyObject {

    func update(with viewModel: MnemonicImportViewModel)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

final class MnemonicImportViewController: BaseViewController {

    var presenter: MnemonicImportPresenter!

    private var viewModel: MnemonicImportViewModel?
    private var didAppear: Bool = false

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ctaButton: Button!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
        let cell = collectionView.visibleCells
            .first(where: { ($0 as? MnemonicImportCell) != nil })
        (cell as? MnemonicImportCell)?.textView.becomeFirstResponder()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    
    @IBAction func ctaAction(_ sender: Any) {
        presenter.handle(.didSelectCta)
    }

    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handle(.didSelectDismiss)
    }
}

// MARK: - Mnemonic

extension MnemonicImportViewController: MnemonicImportView {

    func update(with viewModel: MnemonicImportViewModel) {
        let equalSectionCnt = viewModel.sectionsItems.count == self.viewModel?.sectionsItems.count
        let needsReload = self.needsReload(self.viewModel, viewModel: viewModel)
        self.viewModel = viewModel

        guard let cv = collectionView else {
            return
        }

        ctaButton.setTitle(viewModel.cta, for: .normal)

        let cells = cv.indexPathsForVisibleItems
        let idxs = IndexSet(0..<viewModel.sectionsItems.count)

        if needsReload && didAppear && equalSectionCnt {
            cv.performBatchUpdates({ cv.reloadSections(idxs) })
            return
        }

        updateFootersIfNeeded(viewModel)

        didAppear && equalSectionCnt
            ? cv.performBatchUpdates({ cv.reconfigureItems(at: cells) })
            : cv.reloadData()
    }

    func updateFootersIfNeeded(_ viewModel: MnemonicImportViewModel) {
        guard let _ = viewModel.footers[safe: 0], let cv = collectionView else {
            return
        }

        let kind = UICollectionView.elementKindSectionFooter

        cv.indexPathsForVisibleSupplementaryElements(ofKind: kind).forEach {
            if let sectionFooter = viewModel.footers[safe: $0.section] {
                let footerView = cv.supplementaryView(forElementKind: kind, at: $0)
                (footerView as? SectionLabelFooter)?.update(with: sectionFooter)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension MnemonicImportViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sectionsItems.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.sectionsItems[safe: section]?.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let viewModel = viewModel?.item(at: indexPath) else {
            fatalError("Wrong number of items in section \(indexPath)")
        }
        let cell = cell(cv: collectionView, viewModel: viewModel, idxPath: indexPath)
        if indexPath.section == 1 {

            (cell as? CollectionViewCell)?.cornerStyle = .middle

            if indexPath.item == 0 {
                (cell as? CollectionViewCell)?.cornerStyle = .top
            }

            if indexPath.item == (self.viewModel?.sectionsItems[safe: 1]?.count ?? 0) - 1 {
                (cell as? CollectionViewCell)?.cornerStyle = .bottom
            }
        }
        return cell
    }

    func cell(
        cv: UICollectionView,
        viewModel: MnemonicImportViewModel.Item,
        idxPath: IndexPath
    ) -> UICollectionViewCell {

        switch viewModel {

        case let .mnemonic(mnemonic):
            return collectionView.dequeue(MnemonicImportCell.self, for: idxPath)
                .update(
                    with: mnemonic,
                    textChangeHandler: { value in self.mnemonicDidChange(value) },
                    textEditingEndHandler: nil
                )

        case let .name(name):
            return collectionView.dequeue(
                TextInputCollectionViewCell.self,
                for: idxPath
            ).update(
                with: name,
                textChangeHandler: { value in self.nameDidChange(value) }
            )

        case let .switch(title, onOff):
            return collectionView.dequeue(
                SwitchCollectionViewCell.self,
                for: idxPath
            ).update(
                with: title,
                onOff: onOff,
                handler: { value in self.iCloudBackupDidChange(value) }
            )
        case let .switchWithTextInput(switchWithTextInput):
            return collectionView.dequeue(
                SwitchTextInputCollectionViewCell.self,
                for: idxPath
            ).update(
                with: switchWithTextInput,
                switchAction: { onOff in self.saltSwitchDidChange(onOff) },
                textChangeHandler: { text in self.saltTextDidChange(text) },
                descriptionAction: { self.saltLearnMoreAction() }
            )
        case let .segmentWithTextAndSwitchInput(segmentWithTextAndSwitchInput):
            return collectionView.dequeue(
                SegmentWithTextAndSwitchCell.self,
                for: idxPath
            ).update(
                with: segmentWithTextAndSwitchInput,
                selectSegmentAction: { idx in self.passTypeDidChange(idx) },
                textChangeHandler: { text in self.passwordDidChange(text) },
                switchHandler: { onOff in self.allowFaceIdDidChange(onOff) }
            )
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        switch kind {

        case UICollectionView.elementKindSectionHeader:
            fatalError("Handle header \(kind) \(indexPath)")

        case UICollectionView.elementKindSectionFooter:
            guard let viewModel = viewModel?.footer(at: indexPath.section) else {
                fatalError("Failed to handle \(kind) \(indexPath)")
            }

            let footer = collectionView.dequeue(
                SectionLabelFooter.self,
                for: indexPath,
                kind: kind
            )

            footer.update(with: viewModel)
            return footer

        default:
            
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
        fatalError("Failed to handle \(kind) \(indexPath)")
    }
}

extension MnemonicImportViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        return false
    }

    func mnemonicDidChange(_ mnemonic: String) {
        presenter.handle(.didChangeMnemonic(mnemonic: mnemonic))
    }

    func nameDidChange(_ name: String) {
        presenter.handle(.didChangeName(name: name))
    }

    func iCloudBackupDidChange(_ onOff: Bool) {
        presenter.handle(.didChangeICouldBackup(onOff: onOff))
    }

    func saltSwitchDidChange(_ onOff: Bool) {
        presenter.handle(.saltSwitchDidChange(onOff: onOff))
    }

    func saltTextDidChange(_ text: String) {
        presenter.handle(.didChangeSalt(salt: text))
    }

    func saltLearnMoreAction() {
        presenter.handle(.saltLearnMoreAction)
    }

    func passTypeDidChange(_ idx: Int) {
        presenter.handle(.passTypeDidChange(idx: idx))

    }

    func passwordDidChange(_ text: String) {
        presenter.handle(.passwordDidChange(text: text))
    }

    func allowFaceIdDidChange(_ onOff: Bool) {
        presenter.handle(.allowFaceIdDidChange(onOff: onOff))
    }
}

extension MnemonicImportViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let width = view.bounds.width - Theme.constant.padding * 2

        guard let viewModel = viewModel?.item(at: indexPath) else {
            return CGSize(width: width, height: Theme.constant.cellHeight)
        }

        switch viewModel {
        case .mnemonic:
            return CGSize(width: width, height: Constant.mnemonicCellHeight)
        case let .switchWithTextInput(switchWithTextInput):
            return CGSize(
                width: width,
                height: switchWithTextInput.onOff
                    ? Constant.cellSaltOpenHeight
                    : Constant.cellHeight
            )
        case let .segmentWithTextAndSwitchInput(segmentWithTextAndSwitchInput):
            return CGSize(
                width: width,
                height: segmentWithTextAndSwitchInput.selectedSegment != 2
                    ? Constant.cellPassOpenHeight
                    : Constant.cellHeight
            )
        default:
            return CGSize(width: width, height: Constant.cellHeight)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard viewModel?.header(at: section) != nil else {
            return .zero
        }

        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let footer = viewModel?.footer(at: section) else {
            return .zero
        }

        switch footer {
        case .attrStr:
            return .init(width: view.bounds.width, height: Constant.footerHeight)
        default:
            return .zero
        }
    }
}

extension MnemonicImportViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

// MARK: - Configure UI

private extension MnemonicImportViewController {
    
    func configureUI() {
        title = Localized("newMnemonic.title")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )
        
        ctaButton.style = .primary
    }

    func needsReload(_ preViewModel: MnemonicImportViewModel?, viewModel: MnemonicImportViewModel) -> Bool {
        guard viewModel.sectionsItems.count > 1 ||
              (preViewModel?.sectionsItems.count ?? 0) > 1 else {
            return false
        }

        return (preViewModel?.sectionsItems[safe: 1]?.count ?? 0) !=
            (viewModel.sectionsItems[safe: 1]?.count ?? 0)
    }
}

// MARK: - Constants

private extension MnemonicImportViewController {

    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellHeight: CGFloat = 46
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
        static let footerHeight: CGFloat = 80
    }
}