// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol MnemonicView: AnyObject {

    func update(with viewModel: MnemonicViewModel)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

final class MnemonicViewController: BaseViewController {

    var presenter: MnemonicPresenter!

    private var viewModel: MnemonicViewModel?
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

extension MnemonicViewController: MnemonicView {

    func update(with viewModel: MnemonicViewModel) {
        
        let needsReload = self.needsReload(self.viewModel, viewModel: viewModel)
        self.viewModel = viewModel

        guard let cv = collectionView else {
            return
        }

        ctaButton.apply(style: .primary)
        ctaButton.setTitle(viewModel.cta, for: .normal)

        let cells = cv.indexPathsForVisibleItems
        let idxs = IndexSet(0..<viewModel.sectionsItems.count)

        if needsReload && didAppear {
            cv.performBatchUpdates({ cv.reloadSections(idxs) })
            return
        }

        didAppear
            ? cv.performBatchUpdates({ cv.reconfigureItems(at: cells) })
            : cv.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension MnemonicViewController: UICollectionViewDataSource {

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
        viewModel: MnemonicViewModel.Item,
        idxPath: IndexPath
    ) -> UICollectionViewCell {
        
        switch viewModel {

        case let .mnemonic(mnemonic):
            return collectionView.dequeue(MnemonicCell.self, for: idxPath)
                .update(
                    with: mnemonic,
                    textChangeHandler: { [weak self] text in
                        self?.nameDidChangeMnemonic(text)
                    },
                    textEditingEndHandler: { [weak self] text in
                        self?.nameDidEndEditingMnemonic(text)
                    }
                )

        case let .name(name):
            return collectionView.dequeue(
                MnemonicTextInputCollectionViewCell.self,
                for: idxPath
            ).update(
                with: name,
                textChangeHandler: { value in self.nameDidChange(value) }
            )

        case let .switch(title, onOff):
            return collectionView.dequeue(
                MnemonicSwitchCollectionViewCell.self,
                for: idxPath
            ).update(
                with: title,
                onOff: onOff,
                handler: { value in self.iCloudBackupDidChange(value) }
            )
        case let .switchWithTextInput(switchWithTextInput):
            return collectionView.dequeue(
                MnemonicSwitchTextInputCollectionViewCell.self,
                for: idxPath
            ).update(
                with: switchWithTextInput,
                switchAction: { onOff in self.saltSwitchDidChange(onOff) },
                textChangeHandler: { text in self.saltTextDidChange(text) },
                descriptionAction: { self.saltLearnMoreAction() }
            )
        case let .segmentWithTextAndSwitchInput(segmentWithTextAndSwitchInput):
            return collectionView.dequeue(
                MnemonicSegmentWithTextAndSwitchCell.self,
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
                MnemonicViewSectionLabelFooter.self,
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

extension MnemonicViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        
        guard indexPath == .init(row: 0, section: 0) else { return false }
        
        let cell = collectionView.cellForItem(at: .init(item: 0, section: 0))
        (cell as? MnemonicCell)?.animateCopiedToPasteboard()
        presenter.handle(.didTapMnemonic)
        
        return false
    }

    func nameDidChangeMnemonic(_ text: String) {
        presenter.handle(.didChangeMnemonic(text: text))
    }

    func nameDidEndEditingMnemonic(_ text: String) {
        presenter.handle(.didEndEditingMnemonic(text: text))
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

extension MnemonicViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let width = view.bounds.width - Global.padding * 2

        guard let viewModel = viewModel?.item(at: indexPath) else {
            return CGSize(width: width, height: Global.cellHeight)
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

extension MnemonicViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

// MARK: - Configure UI

private extension MnemonicViewController {
    
    func configureUI() {
        title = Localized("newMnemonic.title")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: .init(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )
    }

    func needsReload(_ preViewModel: MnemonicViewModel?, viewModel: MnemonicViewModel) -> Bool {
        preViewModel?.sectionsItems[1].count != viewModel.sectionsItems[1].count
    }
}

// MARK: - Constants

private extension MnemonicViewController {

    enum Constant {
        
        static let mnemonicCellHeight: CGFloat = 110
        static let cellHeight: CGFloat = 46
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
        static let footerHeight: CGFloat = 80
    }
}
