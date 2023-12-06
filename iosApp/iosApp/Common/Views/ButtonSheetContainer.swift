// Created by web3d3v on 23/11/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

@objc protocol ButtonSheetContainerDelegate: AnyObject {
    func buttonSheetContainer(_ bsc: ButtonSheetContainer, didSelect idx: Int)
    @objc optional
    func buttonSheetContainer(_ bsc: ButtonSheetContainer, expanded: Bool)
    @objc optional
    func buttonSheetContainer(_ bsc: ButtonSheetContainer, contentHeight: CGFloat)
}

class ButtonSheetContainer: UIView, ContentScrollInfo,
        UICollectionViewDataSource, UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {

    weak var delegate: ButtonSheetContainerDelegate?

    //// Hides background when not expanded and there is not content behind.
    var hideBgForNonExpanded: Bool = false
    /// Show handle at the top of the sheet.
    var showHandle: Bool = false
    /// Blur effect has a quirk when going to off screen. This is a problem for
    /// edge swipe sheet container. Set true to mitigate the issue
    var minimizeBgHeight: Bool = false {
        didSet { if oldValue != minimizeBgHeight { setNeedsLayout() } }
    }
    
    private(set) var isExpanded: Bool = false
    private(set) var buttons: [ButtonViewModel] = []
    private(set) var expandedButtons: [ButtonViewModel] = []

    private var compactCount: Int = -1
    private var hiddenButtonsCount: Int = 0
    private var isBehindContent: Bool = false
    private var prevSize: CGSize = .zero
    private lazy var bgView: UIView = newBackgroundView()
    private lazy var cv: UICollectionView = newCollectionView()
    private lazy var layout: UICollectionViewFlowLayout = .init()

    enum SheetState {
        case compact
        case expanded
        case auto
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    func setButtons(
        _ buttons: [ButtonViewModel],
        compactCount: Int = -1,
        sheetState: SheetState = .auto,
        animated: Bool = false,
        expandedButton: [ButtonViewModel] = []
    ) {
        _ = cv.numberOfItems(inSection: 0)
        let oldButtons = self.buttons
        let wasExpanded = isExpanded
        let size = intrinsicContentSize(for: buttons.count)

        self.cv.frame = CGRect(zeroOrigin: size)
        self.compactCount = compactCount
        self.buttons = buttons
        self.expandedButtons = expandedButton.isEmpty ? buttons : expandedButton
        hiddenButtonsCount = max(0, buttons.count - compactCount)

        !animated
            ? cv.reloadData()
            : cv.reloadAnimatedIfNeeded(
            prevVM: ButtonViewModelAutoDiffInfo(oldButtons),
            currVM: ButtonViewModelAutoDiffInfo(buttons)
        )
        setupInsets(
            btnCnt: buttons.count,
            compCnt: compactCount,
            expanded: wasExpanded,
            sheetState: sheetState,
            animated: animated
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard prevSize != bounds.size else { return }
        prevSize = bounds.size

        let chromeHeight = Theme.padding * (showHandle ? 2 : 1)
        var cvBounds = bounds
        cvBounds.origin.y = chromeHeight
        cvBounds.size.height = intrinsicContentSize.height - chromeHeight
        cv.frame = cvBounds

        layout.invalidateLayout()
        layout.itemSize.width = bounds.width - Theme.padding * 2
        layout.itemSize.height = Theme.buttonHeight
        layout.minimumLineSpacing = Theme.padding

        cvBounds.origin.y = 0
        cvBounds.size.height += Theme.buttonHeight
        cvBounds.size.height += minimizeBgHeight ? 0 : Theme.padding.twice
        let transform = bgView.transform
        bgView.transform = .identity
        bgView.frame = cvBounds
        bgView.transform = transform
        handleView()?.center = .init(x: cvBounds.midX, y: Theme.padding)
    }

    func intrinsicContentSize(for btnCnt: Int) -> CGSize {
        CGSize(
            width: (superview?.bounds.width ?? 320),
            height: CGFloat(btnCnt) * Theme.buttonHeight        // buttons
                + CGFloat(max(0, btnCnt - 1)) * Theme.padding   // spaces
                + Theme.padding * (showHandle ?  2 : 1)         // header
        )
    }

    override var intrinsicContentSize: CGSize {
        intrinsicContentSize(for: buttons.count)
    }

    func buttonViewAt(idx: Int) -> UIView? {
        cv.cellForItem(at: IndexPath(item: idx, section: 0))
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        cv.hitTest(convert(point, to: cv), with: event)
    }

    // MARK: - ContentScrollInfo

    func contentMaxY(_ maxY: CGFloat) {
        isBehindContent = maxY > 0 // bounds.height + cv.contentOffset.y
        updateBgViewAlpha()
    }

    // MARK: - Config

    private func setupInsets(
        btnCnt: Int,
        compCnt: Int,
        expanded: Bool,
        sheetState: SheetState,
        animated: Bool = false
    ) {
        let hiddenCnt = CGFloat(hiddenButtonsCount)
        cv.contentInset.top = hiddenCnt * Theme.buttonHeight
            + hiddenCnt * Theme.padding
        setSheetState(
            sheetState == .auto ? expanded ? .expanded : .compact : sheetState,
            animated: animated
        )
    }

    func setSheetState(_ sheetState: SheetState, animated: Bool = true) {
        if sheetState == .expanded { setExpanded(animated) }
        if sheetState == .compact { setCompact(animated) }
    }

    private func setCompact(_ animated: Bool = false) {
        let hiddenCnt = CGFloat(hiddenButtonsCount)
        guard hiddenCnt > 0 else { setExpanded(animated); return }
        let y = cv.contentInset.top
        let tranY = y - Theme.padding * (showHandle ? 2 : 1)
        cv.setContentOffset(.init(x: 0, y: -y), animated: animated)
        !animated ? bgView.transform = CGAffTransTransl(0, ty: tranY) : ()
    }

    private func setExpanded(_ animated: Bool = false) {
        cv.setContentOffset(.zero, animated: animated)
        !animated
            ? bgView.transform = .identity
            : DispatchQueue.main
                .asyncAfter(deadline: .now() + 0.1) { self.layoutBgView() }
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        buttons.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let vm = (isExpanded ? expandedButtons : buttons)[indexPath.item]
        return collectionView.dequeue(ButtonCell.self, for: indexPath)
            .update(with: vm)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        prefetchItemsAt indexPaths: [IndexPath]
    ) {
        // prefetching
    }

    // MARK: - UICollectionViewDelegate
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
         if !isExpanded { setCompact(false) }
         delegate?.buttonSheetContainer(self, didSelect: indexPath.item)
    }
        
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        layoutBgView()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        layoutBgView()
        updateExpanded()
        updateDelegateContentHeight()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
        updateExpanded()
        updateDelegateContentHeight()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateExpanded()
        updateDelegateContentHeight()
    }
    
    private func updateDelegateContentHeight() {
        guard let topView = buttonViewAt(idx: 0) else { return }
        let height = bounds.height - topView.convert(.zero, to: self).y
        delegate?.buttonSheetContainer?(self, contentHeight: height)
    }
    
    // MARK:  - Layout
    
    private func layoutBgView() {
        guard cv.numberOfItems(inSection: 0) > 0 else { return }
        guard let cell = cv.cellForItem(at: IndexPath.zero) else { return }
        let ty = cell.convert(cell.bounds, to: self).origin.y
            - Theme.padding * ( showHandle ? 2 : 1)
        bgView.transform = CGAffineTransformMakeTranslation(0, ty)
        updateBgViewAlpha()
    }
    
    private func updateBgViewAlpha() {
        if isBehindContent {
            guard bgView.alpha != 1 else { return }
            UIView.springAnimate(0.1) { self.bgView.alpha = 1 }
        } else if hideBgForNonExpanded {
            let offsetY = abs(cv.contentOffset.y)
            bgView.alpha = min(1, (1 - offsetY / cv.contentInset.top) * 1.5)
        } else {
            let alpha = hiddenButtonsCount > 0 ? 1.0 : 0.0
            guard alpha != bgView.alpha else { return }
            UIView.springAnimate(0.1) { self.bgView.alpha = alpha }
        }
        handleView()?.isHidden = !showHandle
    }

    private func updateExpanded() {
        guard hiddenButtonsCount > 0 else { return }
        let btnHeight = Theme.buttonHeight
        let offsetY = abs(cv.contentOffset.y)
        if isExpanded && offsetY + btnHeight - cv.contentInset.top > 0 {
            isExpanded = false
            delegate?.buttonSheetContainer?(self, expanded: isExpanded)
            updateVisibleCell()
        }
        if !isExpanded && offsetY < btnHeight * CGFloat(hiddenButtonsCount) / 2 {
            isExpanded = true
            delegate?.buttonSheetContainer?(self, expanded: isExpanded)
            updateVisibleCell()
        }
    }

    private func updateVisibleCell() {
        cv.reconfigureItems(at: cv.indexPathsForVisibleItems)
    }

    private func handleView() -> UIView? {
        ((bgView as? ThemeBlurView)?.contentView ?? bgView)?.subviews.first
    }

    // MARK - Config
    
    private func configureUI() {
        backgroundColor = .clear
        clipsToBounds = false
    }

    private func newCollectionView() -> UICollectionView {
        let cv = TouchPassThroughCollectionView(
            frame: bounds,
            collectionViewLayout: layout
        )
        cv.contentInset.top = Theme.padding
        cv.register(ButtonCell.self)
        cv.backgroundColor = .clear
        cv.dataSource = self
        cv.delegate = self
        cv.prefetchDataSource = self
        cv.alwaysBounceVertical = true
        cv.showsVerticalScrollIndicator = false
        cv.clipsToBounds = false
        cv.topAdditionalTouchMargin = (showHandle ? 2 : 1) - Theme.padding
        cv.isPagingEnabled = true
        addSubview(cv)
        return cv
    }

    private func newBackgroundView() -> UIView {
        let bgView = ThemeBlurView().round()
        insertSubview(bgView, at: 0)
        let pad = Theme.padding
        let frame = CGRect(zeroOrigin: .init(width: pad * 3, height: pad / 4))
        let handleView = UIView(frame: frame).rounded(frame.size.height.half)
        handleView.backgroundColor = Theme.color.bgPrimary
        bgView.contentView.addSubview(handleView)
        return bgView
    }
}

struct ButtonViewModelAutoDiffInfo: AutoDiffInfo {
    private let buttons: Array<ButtonViewModel>

    init(_ buttons: Array<ButtonViewModel>) {
        self.buttons = buttons
    }

    var sectionsCount: Int { 1 }

    func itemCount(_ section: Int) -> Int { buttons.count }

    func itemType(_ idxPath: IndexPath) -> String {
        "\(buttons[idxPath.item].kind)"
    }
}
