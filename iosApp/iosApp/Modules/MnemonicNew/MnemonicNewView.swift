// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicNewViewController: UICollectionViewController {
    @IBOutlet weak var ctaButton: Button!
    
    var presenter: MnemonicNewPresenter!

    private var didAppear: Bool = false
    private var prevSize: CGSize = .zero
    private var cellSize: CGSize = .zero
    private var viewModel: CollectionViewModel.Screen?
    private var cv: CollectionView! { (collectionView as! CollectionView) }
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var interactiveTransitioning: CardFlipInteractiveTransitioning?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        recomputeSizeIfNeeded()
        layoutOverscrollView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
    }

    override func traitCollectionDidChange(
        _ previousTraitCollection: UITraitCollection?
    ) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyTheme(Theme)
        cv?.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - MnemonicView
    
    func update(with viewModel: CollectionViewModel.Screen) {
        self.viewModel = viewModel
        guard let cv = collectionView else { return }
        ctaButton.setTitle(viewModel.ctaItems.last, for: .normal)
        let cells = cv.visibleCells
            .map { cv.indexPath(for: $0) }
            .compactMap { $0 }
        didAppear
            ? cv.performBatchUpdates({ cv.reconfigureItems(at: cells) })
            : cv.reloadData()
    }

    // MARK: - Actions
    
    @IBAction func ctaAction(_ sender: Any) {
        presenter.handleEvent(MnemonicNewPresenterEvent.DidSelectCta())
    }

    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handleEvent(MnemonicNewPresenterEvent.DidSelectDismiss())
    }
}

// MARK: - UICollectionViewDataSource

extension MnemonicNewViewController {

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

    override func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            guard let section = viewModel?.sections[indexPath.section] else {
                fatalError("Failed to handle \(kind) \(indexPath)")
            }
            return cv.dequeue(SectionFooterView.self, for: indexPath, kind: kind)
                .update(with: section)
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
        guard indexPath == .init(row: 0, section: 0) else { return false }
        let cell = collectionView.cellForItem(at: .init(item: 0, section: 0))
        (cell as? MnemonicNewCell)?.animateCopiedToPasteboard()
        presenter.handleEvent(.DidTapMnemonic())
        return false
    }

    func nameDidChange(_ name: String) {
        presenter.handleEvent(.DidChangeName(name: name))
    }

    func iCloudBackupDidChange(_ onOff: Bool) {
        presenter.handleEvent(.DidChangeICouldBackup(onOff: onOff))
    }

    func saltSwitchDidChange(_ onOff: Bool) {
        presenter.handleEvent(.SaltSwitchDidChange(onOff: onOff))
    }

    func saltTextDidChange(_ text: String) {
        presenter.handleEvent(.DidChangeSalt(salt: text))
    }

    func saltLearnAction() {
        presenter.handleEvent(.SaltLearnMoreAction())
    }

    func passTypeDidChange(_ idx: Int) {
        presenter.handleEvent(.PassTypeDidChange(idx: idx.int32))
    }

    func passwordDidChange(_ text: String) {
        presenter.handleEvent(.PasswordDidChange(text: text))
    }

    func allowFaceIdDidChange(_ onOff: Bool) {
        presenter.handleEvent(.AllowFaceIdDidChange(onOff: onOff))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MnemonicNewViewController: UICollectionViewDelegateFlowLayout {

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

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        let size = String.estimateSize(
            viewModel?.sections[section].footer?.text(),
            font: Theme.font.sectionFooter,
            maxWidth: cellSize.width,
            extraHeight: Theme.padding
        )
        return size
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension MnemonicNewViewController: UIViewControllerTransitioningDelegate {

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        let presentedVc = (presented as? UINavigationController)?.topVc
        let sourceNav = (source as? UINavigationController)
        let targetView = (source as? TargetViewTransitionDatasource)?.targetView()
            ?? (sourceNav?.topVc as? TargetViewTransitionDatasource)?.targetView()
            ?? presenting.view
        guard presentedVc == self, let targetView = targetView else {
            animatedTransitioning = nil
            return nil
        }
        animatedTransitioning = CardFlipAnimatedTransitioning(
            targetView: targetView,
            handler: { [weak self] in self?.animatedTransitioning = nil }
        )
        return animatedTransitioning
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard dismissed == self || dismissed == navigationController else {
            animatedTransitioning = nil
            return nil
        }
        let presenting = dismissed.presentingViewController
        guard let visVc = (presenting as? EdgeCardsController)?.visibleViewController,
            let topVc = (visVc as? UINavigationController)?.topVc,
            let targetView = (topVc as? TargetViewTransitionDatasource)?.targetView()
        else {
            animatedTransitioning = nil
            return nil
        }
        animatedTransitioning = CardFlipAnimatedTransitioning(
            targetView: targetView,
            isPresenting: false,
            scaleAdjustment: 0.05,
            handler: { [weak self] in self?.animatedTransitioning = nil }
        )
        return animatedTransitioning
    }

    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning
    ) -> UIViewControllerInteractiveTransitioning? {
        interactiveTransitioning
    }

    @objc func handleGesture(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view.window!)
        let pct = (location.x * 0.5) / view.bounds.width
        switch recognizer.state {
        case .began:
            interactiveTransitioning = CardFlipInteractiveTransitioning(
                handler: { [weak self] in self?.interactiveTransitioning = nil }
            )
            dismiss(animated: true)
        case .changed:
            interactiveTransitioning?.update(pct)
        case .cancelled:
            interactiveTransitioning?.cancel()
        case .ended:
            let completed = recognizer.velocity(in: view.window!).x >= 0
            interactiveTransitioning?.completionSpeed = completed ? 1.5 : 0.1
            completed
                ? interactiveTransitioning?.finish()
                : interactiveTransitioning?.cancel()
        default:
            ()
        }
    }
}

// MARK: - Configure UI

private extension MnemonicNewViewController {
    
    func configureUI() {
        title = Localized("mnemonic.title.new")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            sysImgName: "chevron.left",
            target: self,
            action: #selector(dismissAction(_:))
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
        let edgePan = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleGesture(_:))
        )
        edgePan.edges = [UIRectEdge.left]
        view.addGestureRecognizer(edgePan)
        cv.pinOverscrollToBottom = true
        ctaButton.style = .primary
        applyTheme(Theme)
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

private extension MnemonicNewViewController {

    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
    }
}
