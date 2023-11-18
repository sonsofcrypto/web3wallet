// Created by web3d3v on 17/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

class CollectionViewController: UICollectionViewController,
        UICollectionViewDelegateFlowLayout, ButtonContainerDelegate {
    var didAppear: Bool = false
    var prevSize: CGSize = .zero
    var cellSize: CGSize = .zero
    var viewModel: CollectionViewModel.Screen?
    var cv: CollectionView! { (collectionView as! CollectionView) }
    var ctaButtonsContainer: ButtonContainer = .init()

    var enableCardFlipTransitioning: Bool = false

    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var interactiveTransitioning: CardFlipInteractiveTransitioning?

    deinit { NotificationCenter.default.removeObserver(self) }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        recomputeSizeIfNeeded()
        layoutAboveScrollView()
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

    func configureUI() {
        NotificationCenter.addKeyboardObserver(
            self,
            selector: #selector(keyboardWillShow)
        )
        NotificationCenter.addKeyboardObserver(
            self,
            selector: #selector(keyboardWillHide),
            event: .willHide
        )
        if enableCardFlipTransitioning {
            let edgePan = UIScreenEdgePanGestureRecognizer(
                target: self,
                action: #selector(handleGesture(_:))
            )
            edgePan.edges = [UIRectEdge.left]
            view.addGestureRecognizer(edgePan)
        }
        cv.abovescrollView = ctaButtonsContainer
        cv.pinOverscrollToBottom = true
        cv.stickAbovescrollViewToBottom = true
        cv.abovescrollViewAboveCells = true
        ctaButtonsContainer.delegate = self
        applyTheme(Theme)
    }

    func setCTAButtons(buttons: [ButtonContainer.ButtonViewModel]) {
        let needsLayout = ctaButtonsContainer.buttons.count != buttons.count
        ctaButtonsContainer.setButtons(buttons)
        layoutAboveScrollView()
    }

    func buttonContainer(
        _ buttonContainer: ButtonContainer,
        didSelectButtonAt idx: Int
    ) {
        print("buttonContainer didSelectButtonAt \(idx)")
    }

    func layoutAboveScrollView() {
        cv.abovescrollView?.bounds.size = .init(
            width: view.bounds.width,
            height: ctaButtonsContainer.intrinsicContentSize.height
                + cv.safeAreaInsets.bottom - Theme.paddingHalf
        )
        cv.contentInset.bottom = bottomInset()
    }

    // MARK: - Keyboard handling

    @objc func keyboardWillShow(notification: Notification) {
        let firstResponderIdxPath = cv.indexPathsForVisibleItems.filter {
            cv.cellForItem(at: $0)?.firstResponder != nil
        }.first

        cv.contentInset.bottom = Theme.padding

        if let idxPath = firstResponderIdxPath {
            cv.scrollToItem(at: idxPath, at: .centeredVertically, animated: true)
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        cv.contentInset.bottom = bottomInset()
    }

    // MARK: - Utils

    func viewModel(at idxPath: IndexPath) -> CellViewModel? {
        viewModel?.sections[idxPath.section].items[idxPath.item]
    }

    func applyTheme(_ theme: ThemeProtocol) {
        cv?.separatorInsets = .with(left: theme.padding)
        cv?.sectionBackgroundColor = theme.color.bgPrimary
        cv?.sectionBorderColor = theme.color.collectionSectionStroke
        cv?.separatorColor = theme.color.collectionSeparator
        cv?.contentInset.bottom = bottomInset()
        (cv?.overscrollView?.subviews.first as? UILabel)?
            .textColor = theme.color.textPrimary
    }

    func recomputeSizeIfNeeded() -> Bool {
        guard prevSize.width != view.bounds.size.width else { return false}
        prevSize = view.bounds.size
        cellSize = .init(
            width: view.bounds.size.width - Theme.padding * 2,
            height: Theme.cellHeight
        )
        return true
    }

    func bottomInset() -> CGFloat {
        cv.abovescrollView?.bounds.height ?? Theme.padding
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        String.estimateSize(
            (viewModel?.sections[safe: section]?.header)?.text(),
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
        String.estimateSize(
            viewModel?.sections[section].footer?.text(),
            font: Theme.font.sectionFooter,
            maxWidth: cellSize.width,
            extraHeight: Theme.padding
        )
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension CollectionViewController: UIViewControllerTransitioningDelegate {

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
        guard
            let visVc = (presenting as? EdgeCardsController)?.visibleViewController,
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
