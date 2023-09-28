// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicImportViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ctaButton: Button!
    @IBOutlet weak var ctaButtonBottomConstraint: NSLayoutConstraint!

    var presenter: MnemonicImportPresenter!

    private var viewModel: MnemonicImportViewModel?
    private var didAppear: Bool = false
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var interactiveTransitioning: CardFlipInteractiveTransitioning?

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
    
    @IBAction func ctaAction(_ sender: Any) {
        presenter.handle(MnemonicImportPresenterEvent.DidSelectCta())
    }

    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handle(MnemonicImportPresenterEvent.DidSelectDismiss())
    }
}

extension MnemonicImportViewController {

    func update(with viewModel: MnemonicImportViewModel) {
        let equalSectionCnt = viewModel.sections.count == self.viewModel?.sections.count
        let needsReload = self.needsReload(self.viewModel, viewModel: viewModel)
        self.viewModel = viewModel
        guard let cv = collectionView else { return }
        ctaButton.setTitle(viewModel.cta, for: .normal)
        let cells = cv.indexPathsForVisibleItems
        let idxs = IndexSet(0..<viewModel.sections.count)
        if needsReload && didAppear && equalSectionCnt {
            cv.performBatchUpdates({ cv.reloadSections(idxs) })
            return
        }
        updateFootersIfNeeded(viewModel)
        didAppear && equalSectionCnt
            ? cv.performBatchUpdates({ cv.reconfigureItems(at: cells) })
            : cv.reloadData()
    }
}

private extension MnemonicImportViewController {
    
    func updateFootersIfNeeded(_ viewModel: MnemonicImportViewModel) {
        guard viewModel.sections[safe: 0]?.footer != nil, let cv = collectionView else {
            return
        }
        let kind = UICollectionView.elementKindSectionFooter
        cv.indexPathsForVisibleSupplementaryElements(ofKind: kind).forEach {
            if let sectionFooter = viewModel.sections[safe: $0.section]?.footer {
                let footerView = cv.supplementaryView(forElementKind: kind, at: $0)
                (footerView as? SectionFooterView)?.update(with: sectionFooter)
            }
        }
    }
}

extension MnemonicImportViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.sections[safe: section]?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let item = viewModel?.sections[indexPath.section].items[indexPath.item] else {
            fatalError("Wrong number of items in section \(indexPath)")
        }
        let cell = cell(cv: collectionView, viewModel: item, idxPath: indexPath)
        if indexPath.section == 1 {
            (cell as? CollectionViewCell)?.cornerStyle = .middle
            if indexPath.item == 0 {
                (cell as? CollectionViewCell)?.cornerStyle = .top
            }
            if indexPath.item == (self.viewModel?.sections[safe: 1]?.items.count ?? 0) - 1 {
                (cell as? CollectionViewCell)?.cornerStyle = .bottom
            }
        }
        return cell
    }

    func cell(
        cv: UICollectionView,
        viewModel: MnemonicImportViewModel.SectionItem,
        idxPath: IndexPath
    ) -> UICollectionViewCell {
        if let input = viewModel as? MnemonicImportViewModel.SectionItemMnemonic {
            return collectionView.dequeue(
                MnemonicImportCell.self,
                for: idxPath
            ).update(with: input.mnemonic, handler: mnemonicMnemonicHandler())
        }
        if let input = viewModel as? MnemonicImportViewModel.SectionItemTextInput {
            return collectionView.dequeue(
                TextInputCollectionViewCell.self,
                for: idxPath
            ).update(with: input.viewModel) { [weak self] value in self?.nameDidChange(value) }
        }
        if let input = viewModel as? MnemonicImportViewModel.SectionItemSwitch {
            return collectionView.dequeue(
                SwitchCollectionViewCell.self,
                for: idxPath
            ).update(
                with: input.viewModel,
                handler: { [weak self] value in self?.iCloudBackupDidChange(value) }
            )
        }
        if let input = viewModel as? MnemonicImportViewModel.SectionItemSwitchWithTextInput {
            return collectionView.dequeue(
                SwitchTextInputCollectionViewCell.self,
                for: idxPath
            ).update(
                with: input.viewModel,
                switchAction: { [weak self] onOff in self?.saltSwitchDidChange(onOff) },
                textChangeHandler: { [weak self] text in self?.saltTextDidChange(text) },
                descriptionAction: { [weak self] in self?.saltLearnMoreAction() }
            )
        }
        if let input = viewModel as? MnemonicImportViewModel.SectionItemSegmentWithTextAndSwitchInput {
            return collectionView.dequeue(
                SegmentWithTextAndSwitchCell.self,
                for: idxPath
            ).update(
                with: input.viewModel,
                selectSegmentAction: { [weak self] idx in self?.passTypeDidChange(idx) },
                textChangeHandler: { [weak self] text in
                    guard let self = self else { return }
                    if let indexPath = self.collectionView.indexPath(
                        for: self.collectionView.visibleCells.last!
                    ) {
                        self.collectionView.selectItem(
                            at: indexPath,
                            animated: true,
                            scrollPosition: .top
                        )
                    }
                    self.passwordDidChange(text)
                },
                switchHandler: { [weak self] onOff in
                    guard let self = self else { return }
                    self.allowFaceIdDidChange(onOff)
                }
            )
        }
        fatalError("Not Implemented")
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
            guard let viewModel = viewModel?.sections[indexPath.section].footer else {
                fatalError("Failed to handle \(kind) \(indexPath)")
            }
            let footer = collectionView.dequeue(
                SectionFooterView.self,
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

    func mnemonicMnemonicHandler() -> MnemonicImportCell.Handler {
        .init(onMnemonicChanged: onMnemonicChanged())
    }
    
    func onMnemonicChanged() -> MnemonicImportCell.OnMnemonicChanged {
        {
            [weak self] info in
            guard let self = self else { return }
            self.presenter.handle(
                .MnemonicChanged(
                    to: info.mnemonic,
                    selectedLocation: info.selectedLocation.int32
                )
            )
        }
    }

    func nameDidChange(_ name: String) {
        presenter.handle(MnemonicImportPresenterEvent.DidChangeName(name: name))
    }

    func iCloudBackupDidChange(_ onOff: Bool) {
        presenter.handle(MnemonicImportPresenterEvent.DidChangeICouldBackup(onOff: onOff))
    }

    func saltSwitchDidChange(_ onOff: Bool) {
        presenter.handle(MnemonicImportPresenterEvent.SaltSwitchDidChange(onOff: onOff))
    }

    func saltTextDidChange(_ text: String) {
        presenter.handle(MnemonicImportPresenterEvent.DidChangeSalt(salt: text))
    }

    func saltLearnMoreAction() {
        presenter.handle(MnemonicImportPresenterEvent.SaltLearnMoreAction())
    }

    func passTypeDidChange(_ idx: Int) {
        presenter.handle(MnemonicImportPresenterEvent.PassTypeDidChange(idx: idx.int32))
    }

    func passwordDidChange(_ text: String) {
        presenter.handle(MnemonicImportPresenterEvent.PasswordDidChange(text: text))
    }

    func allowFaceIdDidChange(_ onOff: Bool) {
        presenter.handle(MnemonicImportPresenterEvent.AllowFaceIdDidChange(onOff: onOff))
    }
}

extension MnemonicImportViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = view.bounds.width - Theme.padding * 2
        guard let viewModel = viewModel?.sections[indexPath.section].items[indexPath.item] else {
            return CGSize(width: width, height: Theme.cellHeightLarge)
        }
        if viewModel is MnemonicImportViewModel.SectionItemMnemonic {
            return CGSize(width: width, height: Constant.mnemonicCellHeight)
        }
        if let input = viewModel as? MnemonicImportViewModel.SectionItemSwitchWithTextInput {
            return CGSize(
                width: width,
                height: input.viewModel.onOff
                    ? Constant.cellSaltOpenHeight
                    : Constant.cellHeight
            )
        }
        if let input = viewModel as? MnemonicImportViewModel.SectionItemSegmentWithTextAndSwitchInput {
            return CGSize(
                width: width,
                height: input.viewModel.selectedSegment != 2
                    ? Constant.cellPassOpenHeight
                    : Constant.cellHeight
            )
        }
        return CGSize(width: width, height: Constant.cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        .zero
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        guard viewModel?.sections[section].footer != nil else { return .zero }
        return .init(width: view.bounds.width, height: Constant.footerHeight)
    }
}

extension MnemonicImportViewController: UIScrollViewDelegate { }

extension MnemonicImportViewController: UIViewControllerTransitioningDelegate {

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

private extension MnemonicImportViewController {
    
    func configureUI() {
        title = Localized("mnemonic.title.import")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: "chevron.left".assetImage,
            style: .plain,
            target: self,
            action: #selector(dismissAction(_:))
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let constraint = collectionView.bottomAnchor.constraint(
            equalTo: view.keyboardLayoutGuide.topAnchor
        )
        constraint.priority = .required
        constraint.isActive = true
        NotificationCenter.default.addObserver(
            self, selector: #selector(showKeyboard),
            name: UIApplication.keyboardWillShowNotification,
            object: nil
        )
        ctaButton.style = .primary
        let edgePan = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleGesture(_:))
        )
        edgePan.edges = [UIRectEdge.left]
        view.addGestureRecognizer(edgePan)
        // TODO: Smell
        let window = AppDelegate.keyWindow()
        ctaButtonBottomConstraint.constant = window?.safeAreaInsets.bottom == 0
            ? -Theme.padding
            : 0
    }
    
    @objc func showKeyboard(notification: Notification) {
        guard
            let firstResponder = collectionView.firstResponder,
            let keyboardFrame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue
        else { return }
        let frame = view.convert(firstResponder.bounds, from: firstResponder)
        let y = frame.maxY + Theme.padding * 2
        let keyboardY = keyboardFrame.cgRectValue.origin.y - 40
        guard y > keyboardY else { return }
        if
            let collectionView = collectionView,
            let indexPath = self.collectionView.indexPath(
                for: self.collectionView.visibleCells.last!
            )
        {
            collectionView.scrollToItem(
                at: indexPath,
                at: .top,
                animated: true
            )
        }
    }

    func needsReload(_ preViewModel: MnemonicImportViewModel?, viewModel: MnemonicImportViewModel) -> Bool {
        guard viewModel.sections.count > 1 ||
              (preViewModel?.sections.count ?? 0) > 1 else {
            return false
        }
        return (preViewModel?.sections[safe: 1]?.items.count ?? 0) !=
            (viewModel.sections[safe: 1]?.items.count ?? 0)
    }
}

private extension MnemonicImportViewController {
    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellHeight: CGFloat = 46
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
        static let footerHeight: CGFloat = 80
    }
}
