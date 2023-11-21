// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

final class SignersViewController: BaseViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoAnimView: LogoAnimView!
    @IBOutlet weak var openBetaView: UIStackView!
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    @IBOutlet weak var buttonBackgroundView: UIVisualEffectView!
    @IBOutlet weak var buttonHandleView: UIView!
    @IBOutlet weak var buttonsCollectionTopConstraint: NSLayoutConstraint!
    
    var presenter: SignersPresenter!

    private var viewModel: SignersViewModel?
    private var transitionTargetView: SignersViewModel.TransitionTargetView
        = SignersViewModel.TransitionTargetViewNone()
    private var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    private var prevViewSize: CGSize = .zero
    private var needsLayoutUI: Bool = false
    private var viewDidAppear: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        presenter?.present()
        prevViewSize = view.bounds.size
        buttonsCollectionTopConstraint.constant = 0
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if view.bounds.size != prevViewSize {
            [collectionView, buttonsCollectionView].forEach {
                $0.frame = view.bounds
            }
            collectionView.collectionViewLayout.invalidateLayout()
            buttonsCollectionView.collectionViewLayout.invalidateLayout()
            prevViewSize = view.bounds.size
            needsLayoutUI = true
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsLayoutUI {
            configureInsets()
            setButtonsSheetMode(viewModel?.buttons.mode, animated: false)
            layoutButtonsBackground()
            needsLayoutUI = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateIntro()
        collectionView.deselectAllExcept(selectedIdxPaths())
        buttonsCollectionView.deselectAllExcept()
        viewDidAppear = true
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        collectionView.collectionViewLayout.invalidateLayout()
        buttonsCollectionView.collectionViewLayout.invalidateLayout()
        needsLayoutUI = true
    }
}

// MARK: - KeyStoreView
extension SignersViewController {

    func update(with viewModel: SignersViewModel) {
        self.viewModel?.buttons.mode != viewModel.buttons.mode
            ? setButtonsSheetMode(viewModel.buttons.mode, animated: viewDidAppear)
            : ()
        self.viewModel = viewModel
        collectionView.reloadData()
        updateLogo(viewModel)
        updateTargetView(targetView: viewModel.targetView)
        buttonsCollectionView.deselectAllExcept()
        collectionView.deselectAllExcept(
            selectedIdxPaths(),
            animated: presentedViewController == nil,
            scrollPosition: .centeredVertically
        )
    }
    
    func updateTargetView(targetView: SignersViewModel.TransitionTargetView) {
        transitionTargetView = targetView
    }
}

// MARK: - UICollectionViewDataSource
extension SignersViewController: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        if collectionView == buttonsCollectionView {
            return viewModel?.buttons.buttons.count ?? 0
        }
        return viewModel?.items.count ?? 0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        switch collectionView {
            
        case buttonsCollectionView:
            let button = viewModel?.buttons.buttons[indexPath.item]
            return collectionView.dequeue(
                ButtonsSheetViewCell.self,
                for: indexPath
            ).update(with: button)
            
        default:
            return collectionView.dequeue(SignersCell.self, for: indexPath)
                .update(
                    with: viewModel?.items[indexPath.item],
                    handler: .init(accessoryHandler: { [weak self] in
                        self?.presenter.handleEvent(
                            .SelectAccessory(idx: indexPath.item.int32)
                        )
                    }),
                    index: indexPath.item
                )
        }
    }
}

extension SignersViewController: UICollectionViewDelegate {

    func collectionView(
            _ collectionView: UICollectionView,
            didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == buttonsCollectionView {
            presenter.handleEvent(.SelectButtonAt(idx: indexPath.item.int32))
            return
        }
        presenter.handleEvent(.SelectSignerItemAt(idx: indexPath.item.int32))
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        layoutButtonsBackground()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        layoutButtonsBackground()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateSheetModeIfNeeded(scrollView)
    }
}

extension SignersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        .init(
            width: view.bounds.width - Theme.padding * 2,
            height: collectionView == buttonsCollectionView
            ? Theme.buttonHeight
            : Theme.cellHeightLarge
        )
    }
}

// MARK: - Configure UI
extension SignersViewController {
    
    func configureUI() {
        title = Localized("wallets")
        collectionView.showsVerticalScrollIndicator = false
        configureInsets()
        buttonBackgroundView.layer.cornerRadius = Theme.cornerRadius
        buttonBackgroundView.layer.maskedCorners = [
            .layerMaxXMinYCorner,
            .layerMinXMinYCorner
        ]
        buttonBackgroundView.contentView.backgroundColor = Theme.color.bgGradientTop.withAlpha(0.4)
        buttonHandleView.backgroundColor = Theme.color.textTertiary
        buttonHandleView.layer.cornerRadius = buttonHandleView.frame.size.height.half
        (view as? ThemeGradientView)?.topClipEnabled = true
    }

    func updateLogo(_ viewModel: SignersViewModel) {
        // Adding first wallet
        if !logoAnimView.isHidden && !viewModel.isEmpty {
            UIView.animate(
                withDuration: 0.6,
                delay: 0.3, animations: {
                    self.logoAnimView.alpha = 0
                    self.openBetaView.alpha = 0
                },
                completion: { _ in
                    self.logoAnimView.isHidden = true
                    self.openBetaView.isHidden = true
                }
            )
        // Removing last wallet
        } else if logoAnimView.isHidden && viewModel.isEmpty {
            animateIntro(false)
        }
    }

    func selectedIdxPaths() -> [IndexPath] {
        guard let viewModel = viewModel, !viewModel.items.isEmpty else { return [] }
        return viewModel.selectedIdxs.map { IndexPath(item: $0.intValue, section: 0) }
    }
}

// MARK: - ButtonsSheet handling
extension SignersViewController {

    func setButtonsSheetMode(
        _ mode: SignersViewModel.ButtonSheetViewModelSheetMode? = .compact,
        animated: Bool = true
    ) {
        let targetMode = viewDidAppear ? mode : .hidden
        buttonsCollectionView.reloadData()
        guard let mode = targetMode,
              let cv = buttonsCollectionView,
              !cv.isDragging else {
            return
        }
        switch mode {
        case .hidden:
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -view.bounds.height),
                animated: false
            )
        case .compact:
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -cv.contentInset.top - cv.safeAreaInsets.top),
                animated: animated
            )
        case .expanded:
            let y = view.bounds.height - cv.contentSize.height - cv.safeAreaInsets.bottom
            buttonsCollectionView.setContentOffset(
                CGPoint(x: 0, y: -y),
                animated: animated
            )
        default:
            fatalError("Option not handled")
        }
    }

    func configureInsets() {
        let inset = view.bounds.height
            - Theme.buttonHeight * 3
            - Theme.padding * 4
            - buttonsCollectionView.safeAreaInsets.top
            + 2
        buttonsCollectionView.contentInset.top = inset
        collectionView.contentInset.bottom = view.bounds.height - inset
    }

    func layoutButtonsBackground() {
        guard let topCell = buttonsCollectionView.visibleCells
                .sorted(by: { $0.frame.minY < $1.frame.minY })
                .first else {
            buttonBackgroundView.frame = .zero
            return
        }

        let top = topCell.convert(topCell.bounds.minXY, to: view)
        buttonBackgroundView.frame = CGRect(
            x: 0,
            y: top.y - Theme.padding * 2,
            width: view.bounds.width,
            height: view.bounds.height - top.y + Theme.padding * 2
        )

        guard let cv = buttonsCollectionView else { return }

        if viewModel?.buttons.mode == .compact,
           (viewModel?.items.count ?? 0) > 4,
           let idxPath = collectionView.indexPathsForVisibleItems
               .sorted(by: { $0.item < $1.item }).last,
           let cell = collectionView.cellForItem(at: idxPath) {
                let maxY = cell.convert(cell.bounds, to: view).maxY
                let alpha = maxY > buttonBackgroundView.frame.minY ? 1 : 0
                UIView.animate(withDuration: 0.2) {
                    self.buttonBackgroundView.alpha = CGFloat(alpha)
                }
        } else {
            let offsetCompact = cv.contentInset.top + cv.safeAreaInsets.top
            let offsetExpanded = view.bounds.height - cv.contentSize.height
                - cv.safeAreaInsets.bottom
            let alpha = (offsetCompact + cv.contentOffset.y)
                / (offsetCompact - offsetExpanded)
            buttonBackgroundView.alpha = min(1, max(0, alpha))
        }
    }

    func updateSheetModeIfNeeded(_ scrollView: UIScrollView) {
        guard scrollView == buttonsCollectionView else { return }
        layoutButtonsBackground()
        guard scrollView.isDragging else { return }
        let cellCnt = buttonsCollectionView.visibleCells.count
        presenter.handleEvent(
            .ChangeButtonsSheetMode(mode: cellCnt > 4 ? .expanded : .compact)
        )
    }
}

// MARK: - Into animations
extension SignersViewController {

    func animateIntro(_ animateButtons: Bool = true) {
        guard viewModel?.isEmpty ?? false else {
            return
        }
        logoAnimView.isHidden = false
        logoAnimView.alpha = 0.001
        logoAnimView.animate()
        if animateButtons {
            animateButtonsIntro()
        }
        animateOpenBeta()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            self?.logoAnimView.alpha = 1
            self?.logoAnimView.animate()
        }
    }

    func animateButtonsIntro() {
        setButtonsSheetMode(.hidden, animated: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) { [weak self] in
            self?.setButtonsSheetMode(.compact, animated: true)
        }
    }

    func animateOpenBeta() {
        let views = openBetaView.arrangedSubviews.map { $0 as? UIImageView }
        for (idx, view) in views.compactMap({$0}).enumerated() {
            view.alpha = 0.2
            animateLetter(view, delay: (idx > 4 ? 0.1 * Double(idx) : 0) + 3)
        }
        openBetaView.isHidden = false
        UIView.animate(withDuration: 1) { self.openBetaView.alpha = 1 }
    }

    func animateLetter(_ view: UIView, delay: TimeInterval) {
        UIView.springAnimate(
            0.7,
            delay: delay,
            damping: 0.01,
            velocity: 0.8,
            animations: { view.alpha = 1 }
        )
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension SignersViewController: TargetViewTransitionDatasource {

    func targetView() -> UIView? {
        if let input = transitionTargetView as? SignersViewModel            .TransitionTargetViewKeyStoreItemAt {
                let idxPath = IndexPath(item: input.idx.int, section: 0)
                return collectionView.cellForItem(at: idxPath) ?? view
        }
        if let input = transitionTargetView as? SignersViewModel            .TransitionTargetViewButtonAt {
                let idxPath = IndexPath(item: input.idx.int, section: 0)
                return buttonsCollectionView.cellForItem(at: idxPath) ?? view
        }
        return nil
    }
}
