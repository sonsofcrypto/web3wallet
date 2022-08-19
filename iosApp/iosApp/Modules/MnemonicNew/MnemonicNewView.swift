// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol MnemonicNewView: AnyObject {

    func update(with viewModel: MnemonicNewViewModel)
    func dismiss(animated flag: Bool, completion: (() -> Void)?)
}

final class MnemonicNewViewController: BaseViewController {

    var presenter: MnemonicNewPresenter!

    private var viewModel: MnemonicNewViewModel?
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

extension MnemonicNewViewController: MnemonicNewView {

    func update(with viewModel: MnemonicNewViewModel) {
        let needsReload = self.needsReload(self.viewModel, viewModel: viewModel)
        self.viewModel = viewModel

        guard let cv = collectionView else {
            return
        }

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

extension MnemonicNewViewController: UICollectionViewDataSource {

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
        viewModel: MnemonicNewViewModel.Item,
        idxPath: IndexPath
    ) -> UICollectionViewCell {

        switch viewModel {

        case let .mnemonic(mnemonic):
            return collectionView.dequeue(MnemonicNewCell.self, for: idxPath)
                .update(
                    with: mnemonic,
                    textChangeHandler: nil,
                    textEditingEndHandler: nil
                )

        case let .name(name):
            return collectionView.dequeue(
                TextInputCollectionViewCell.self,
                for: idxPath
            ).update(
                with: name,
                textChangeHandler: { [weak self] value in
                    guard let self = self else { return }
                    self.nameDidChange(value)
                }
            )

        case let .switch(title, onOff):
            return collectionView.dequeue(
                SwitchCollectionViewCell.self,
                for: idxPath
            ).update(
                with: title,
                onOff: onOff,
                handler: { [weak self] value in
                    guard let self = self else { return }
                    self.iCloudBackupDidChange(value)
                }
            )
        case let .switchWithTextInput(switchWithTextInput):
            return collectionView.dequeue(
                SwitchTextInputCollectionViewCell.self,
                for: idxPath
            ).update(
                with: switchWithTextInput,
                switchAction: { [weak self] onOff in
                    guard let self = self else { return }
                    self.saltSwitchDidChange(onOff)
                },
                textChangeHandler: { [weak self] text in
                    guard let self = self else { return }
                    self.saltTextDidChange(text)
                },
                descriptionAction: { [weak self] in
                    guard let self = self else { return }
                    self.saltLearnMoreAction()
                }
            )
        case let .segmentWithTextAndSwitchInput(segmentWithTextAndSwitchInput):
            return collectionView.dequeue(
                SegmentWithTextAndSwitchCell.self,
                for: idxPath
            ).update(
                with: segmentWithTextAndSwitchInput,
                selectSegmentAction: { [weak self] idx in
                    guard let self = self else { return }
                    self.passTypeDidChange(idx)
                },
                textChangeHandler: { [weak self] text in
                    guard let self = self else { return }
                    self.passwordDidChange(text)
                },
                switchHandler: { [weak self] onOff in
                    guard let self = self else { return }
                    self.allowFaceIdDidChange(onOff)
                }
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

extension MnemonicNewViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        
        guard indexPath == .init(row: 0, section: 0) else { return false }
        
        let cell = collectionView.cellForItem(at: .init(item: 0, section: 0))
        (cell as? MnemonicNewCell)?.animateCopiedToPasteboard()
        presenter.handle(.didTapMnemonic)
        
        return false
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

extension MnemonicNewViewController: UICollectionViewDelegateFlowLayout {

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

extension MnemonicNewViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionView.visibleCells.forEach { $0.resignFirstResponder() }
    }
}

// MARK: - Configure UI

private extension MnemonicNewViewController {
    
    func configureUI() {
        title = Localized("newMnemonic.title")

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: "chevron.left".assetImage,
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )
        
        ctaButton.style = .primary
    }

    func needsReload(_ preViewModel: MnemonicNewViewModel?, viewModel: MnemonicNewViewModel) -> Bool {
        preViewModel?.sectionsItems[1].count != viewModel.sectionsItems[1].count
    }
}

// MARK: - Constants

private extension MnemonicNewViewController {

    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellHeight: CGFloat = 46
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
        static let footerHeight: CGFloat = 80
    }
}
