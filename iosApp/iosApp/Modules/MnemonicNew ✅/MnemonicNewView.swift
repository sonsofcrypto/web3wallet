// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class MnemonicNewViewController: BaseViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var ctaButton: Button!
    @IBOutlet weak var ctaButtonBottomConstraint: NSLayoutConstraint!

    var presenter: MnemonicNewPresenter!

    private var viewModel: MnemonicNewViewModel?
    private var didAppear: Bool = false
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didAppear = true
    }
    
    @IBAction func ctaAction(_ sender: Any) {
        presenter.handle(event: MnemonicNewPresenterEvent.DidSelectCta())
    }

    @IBAction func dismissAction(_ sender: Any?) {
        presenter.handle(event: MnemonicNewPresenterEvent.DidSelectDismiss())
    }
}

// MARK: - Mnemonic

extension MnemonicNewViewController {

    func update(with viewModel: MnemonicNewViewModel) {
        self.viewModel = viewModel
        guard let cv = collectionView else { return }
        ctaButton.setTitle(viewModel.cta, for: .normal)
        let cells = cv.indexPathsForVisibleItems
        didAppear
            ? cv.performBatchUpdates({ cv.reconfigureItems(at: cells) })
            : cv.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension MnemonicNewViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.sections.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.sections[safe: section]?.items.count ?? 0
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
        viewModel: MnemonicNewViewModel.SectionItem,
        idxPath: IndexPath
    ) -> UICollectionViewCell {
        if let input = viewModel as? MnemonicNewViewModel.SectionItemMnemonic {
            return collectionView.dequeue(
                MnemonicNewCell.self,
                for: idxPath
            ).update(with: input)
        }
        if let input = viewModel as? MnemonicNewViewModel.SectionItemTextInput {
            return collectionView.dequeue(
                TextInputCollectionViewCell.self,
                for: idxPath
            ).update(with: input.viewModel) { [weak self] value in self?.nameDidChange(value) }
        }
        if let input = viewModel as? MnemonicNewViewModel.SectionItemSwitch {
            return collectionView.dequeue(
                SwitchCollectionViewCell.self,
                for: idxPath
            ).update(
                with: input.viewModel,
                handler: { [weak self] value in self?.iCloudBackupDidChange(value) }
            )
        }
        if let input = viewModel as? MnemonicNewViewModel.SectionItemSwitchWithTextInput {
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
        if let input = viewModel as? MnemonicNewViewModel.SectionItemSegmentWithTextAndSwitchInput {
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
        fatalError("Not implemented")
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

extension MnemonicNewViewController: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        guard indexPath == .init(row: 0, section: 0) else { return false }
        let cell = collectionView.cellForItem(at: .init(item: 0, section: 0))
        (cell as? MnemonicNewCell)?.animateCopiedToPasteboard()
        presenter.handle(event: MnemonicNewPresenterEvent.DidTapMnemonic())
        return false
    }

    func nameDidChange(_ name: String) {
        presenter.handle(event: MnemonicNewPresenterEvent.DidChangeName(name: name))
    }

    func iCloudBackupDidChange(_ onOff: Bool) {
        presenter.handle(event: MnemonicNewPresenterEvent.DidChangeICouldBackup(onOff: onOff))
    }

    func saltSwitchDidChange(_ onOff: Bool) {
        presenter.handle(event: MnemonicNewPresenterEvent.SaltSwitchDidChange(onOff: onOff))
    }

    func saltTextDidChange(_ text: String) {
        presenter.handle(event: MnemonicNewPresenterEvent.DidChangeSalt(salt: text))
    }

    func saltLearnMoreAction() {
        presenter.handle(event: MnemonicNewPresenterEvent.SaltLearnMoreAction())
    }

    func passTypeDidChange(_ idx: Int) {
        presenter.handle(event: MnemonicNewPresenterEvent.PassTypeDidChange(idx: idx.int32))
    }

    func passwordDidChange(_ text: String) {
        presenter.handle(event: MnemonicNewPresenterEvent.PasswordDidChange(text: text))
    }

    func allowFaceIdDidChange(_ onOff: Bool) {
        presenter.handle(event: MnemonicNewPresenterEvent.AllowFaceIdDidChange(onOff: onOff))
    }
}

extension MnemonicNewViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = view.bounds.width - Theme.constant.padding * 2
        guard let viewModel = viewModel?.sections[indexPath.section].items[indexPath.item] else {
            return CGSize(width: width, height: Theme.constant.cellHeight)
        }
        if viewModel is MnemonicNewViewModel.SectionItemMnemonic {
            return CGSize(width: width, height: Constant.mnemonicCellHeight)
        }
        if let input = viewModel as? MnemonicNewViewModel.SectionItemSwitchWithTextInput {
            return CGSize(
                width: width,
                height: input.viewModel.onOff
                    ? Constant.cellSaltOpenHeight
                    : Constant.cellHeight
            )
        }
        if let input = viewModel as? MnemonicNewViewModel.SectionItemSegmentWithTextAndSwitchInput {
            return CGSize(
                width: width,
                height: input.viewModel.onOff
                    ? Constant.cellSaltOpenHeight
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

extension MnemonicNewViewController: UIScrollViewDelegate {
    
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
        title = Localized("mnemonicNew.title")
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
            self,
            selector: #selector(showKeyboard),
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
        let window = UIApplication.shared.keyWindow
        ctaButtonBottomConstraint.constant = window?.safeAreaInsets.bottom == 0
            ? -Theme.constant.padding
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
        let y = frame.maxY + Theme.constant.padding * 2
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
}

// MARK: - Constants

private extension MnemonicNewViewController {

    enum Constant {
        static let mnemonicCellHeight: CGFloat = 110
        static let cellHeight: CGFloat = 46
        static let cellSaltOpenHeight: CGFloat = 142
        static let cellPassOpenHeight: CGFloat = 138
        static let cellPassOpenHeightHint: CGFloat = 138 + 16
        static let footerHeight: CGFloat = 80
    }
}
