// Created by web3d4v on 12/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicConfirmationViewController: UICollectionViewController,
    UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var ctaButton: Button!

    var presenter: MnemonicConfirmationPresenter!

    private var didAppear: Bool = false
    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero
    private var mnemonicInputViewModel: MnemonicInputViewModel?
    private var viewModel: CollectionViewModel.Screen?
    private var cv: CollectionView! { (collectionView as! CollectionView) }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        recomputeSizeIfNeeded()
        layoutOverscrollView()
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

        guard let cv = collectionView else { return }
        ctaButton.setTitle(viewModel.ctaItems.last?.title, for: .normal)

        let cells = cv.visibleCells
            .map { cv.indexPath(for: $0) }
            .compactMap { $0 }

        didAppear
            ? cv.performBatchUpdates({ cv.reconfigureItems(at: cells) })
            : cv.reloadData()
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
        case let vm as CellViewModel.Text:
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
                .update(with: viewModel?.sections[indexPath.section])
        default:
            fatalError("Failed to handle \(kind) \(indexPath)")
        }
    }

    // MARK: - CTAs

    @IBAction func ctaAction(_ sender: Any) {
        presenter.handleEvent(.Confirm())
    }

    @IBAction func dismissAction(_ sender: Any?) {
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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        String.estimateSize(
            viewModel?.sections[section].header?.text(),
            font: Theme.font.sectionHeader,
            maxWidth: cellSize.width,
            extraHeight: Theme.padding.twice,
            minHeight: Theme.padding
        )
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        .zero
    }
}

// MARK: - Configure

private extension MnemonicConfirmationViewController {
    
    func configureUI() {
        title = Localized("mnemonicConfirmation.title")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            sysImgName: "xmark",
            target: self,
            action: #selector(dismissAction)
        )
        NotificationCenter.addKeyboardObserver(
            self,
            selector: #selector(keyboardWillShow)
        )
        NotificationCenter.addKeyboardObserver(
            self,
            selector: #selector(keyboardWillHide),
            event: .willHide
        )
        cv.pinOverscrollToBottom = true
        applyTheme(Theme)
        ctaButton.style = .primary
    }

    func layoutOverscrollView() {
        ctaButton.bounds.size.height = Theme.buttonHeight
        cv.abovescrollView?.bounds.size.width = view.bounds.size.width
        cv.abovescrollView?.bounds.size.height = ctaButton.bounds.height
            + view.safeAreaInsets.bottom
            + Theme.padding
    }

    func applyTheme(_ theme: ThemeProtocol) {
        cv?.separatorInsets = .with(left: theme.padding)
        cv?.sectionBackgroundColor = theme.color.bgPrimary
        cv?.sectionBorderColor = theme.color.collectionSectionStroke
        cv?.separatorColor = theme.color.collectionSeparator
        (cv?.overscrollView?.subviews.first as? UILabel)?
            .textColor = theme.color.textPrimary
    }

    @objc func keyboardWillShow(notification: Notification) {
        let firstResponderIdxPath = cv.indexPathsForVisibleItems.filter {
            cv.cellForItem(at: $0)?.firstResponder != nil
        }.first

        if let idxPath = firstResponderIdxPath {
            cv.scrollToItem(at: idxPath, at: .centeredVertically, animated: true)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        collectionView.contentInset.bottom = Theme.padding * 2
    }

    func viewModel(at idxPath: IndexPath) -> CellViewModel? {
        return viewModel?.sections[idxPath.section].items[idxPath.item]
    }

    func recomputeSizeIfNeeded() {
        guard prevSize.width != view.bounds.size.width else { return }
        prevSize = view.bounds.size
        cellSize = .init(
            width: view.bounds.size.width - Theme.padding * 2,
            height: Theme.cellHeight
        )
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
