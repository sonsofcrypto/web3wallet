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
        UICollectionViewDelegateFlowLayout {

    weak var delegate: ButtonSheetContainerDelegate?

    var hideBgForNonExpanded: Bool = false
    var showHandle: Bool = false
    
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
            wasExpanded: wasExpanded,
            sheetState: sheetState,
            animated: animated
        )
    }

    func intrinsicContentSize(for btnCnt: Int) -> CGSize {
        CGSize(
            width: (superview?.bounds.width ?? 320),
            height: CGFloat(btnCnt) * Theme.buttonHeight
                + max(0, CGFloat(btnCnt - 1)) * Theme.padding
                + Theme.padding // Extra sheet when header absent
                + (showHandle ? Theme.padding * 1 : 0) // Header
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard prevSize != bounds.size else { return }

        prevSize = bounds.size

        var cvBounds = bounds
        cvBounds.size.height = intrinsicContentSize.height
        cv.frame = cvBounds

        layout.invalidateLayout()
        layout.itemSize.width = bounds.width - Theme.padding * 2
        layout.itemSize.height = Theme.buttonHeight
        layout.minimumInteritemSpacing = Theme.padding
        layout.minimumLineSpacing = Theme.padding

        cvBounds.size.height += Theme.buttonHeight + Theme.padding
        let transform = bgView.transform
        bgView.transform = .identity
        bgView.frame = cvBounds
        bgView.transform = transform
        handleView()?.center = .init(x: cvBounds.midX, y: Theme.padding)
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
        isBehindContent = maxY > bounds.height + cv.contentOffset.y
        updateBgViewAlpha()
    }

    // MARK: - Config

    private func setupInsets(
        btnCnt: Int,
        compCnt: Int,
        wasExpanded: Bool,
        sheetState: SheetState,
        animated: Bool = false
    ) {
        let hiddenCnt = CGFloat(hiddenButtonsCount)
        cv.contentInset.top = hiddenCnt * Theme.buttonHeight
            + max(0, (hiddenCnt - 1)) * Theme.padding
            + Theme.padding
        switch sheetState {
        case .expanded:
            setExpanded(animated)
        case .compact:
            setCompact(animated)
        case .auto:
            wasExpanded ? setExpanded(animated) : setCompact(animated)
        }
        updateBgViewAlpha()
    }

    func setSheetState(_ sheetState: SheetState, animated: Bool = true) {
        switch sheetState {
        case .expanded: setExpanded(animated)
        case .compact: setCompact(animated)
        default: ()
        }
    }

    private func setCompact(_ animated: Bool = false) {
        let hiddenCnt = CGFloat(hiddenButtonsCount)
        guard hiddenCnt > 0 else { setExpanded(animated); return }
        let y = hiddenCnt * Theme.buttonHeight + hiddenCnt * Theme.padding
        let tranY = y - Theme.padding
        cv.setContentOffset(.init(x: 0, y: -y), animated: animated)
        !animated ? bgView.transform = CGAffTransTransl(0, ty: tranY) : ()
    }

    private func setExpanded(_ animated: Bool = false) {
        cv.setContentOffset(.init(x: 0, y: -Theme.padding), animated: animated)
        !animated
            ? bgView.transform = .identity
            : DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.layoutBgView()
            }
    }

    private func updateExpanded() {
        guard hiddenButtonsCount > 0 else { return }
        if isExpanded
           && abs(cv.contentOffset.y) + Theme.buttonHeight - cv.contentInset.top > 0 {
            isExpanded = false
            delegate?.buttonSheetContainer?(self, expanded: isExpanded)
            updateVisibleCell()
        }
        if !isExpanded && abs(cv.contentOffset.y) < (Theme.buttonHeight * CGFloat(hiddenButtonsCount) / 2) {
            isExpanded = true
            delegate?.buttonSheetContainer?(self, expanded: isExpanded)
            updateVisibleCell()
        }
    }
    
    private func updateVisibleCell() {
        cv.reconfigureItems(at: cv.indexPathsForVisibleItems)
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
        updateExpanded()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        layoutBgView()
        updateExpanded()
        updateDelegateContentHeight()
    }

    func scrollViewDidEndDragging(
        _ scrollView: UIScrollView,
        willDecelerate decelerate: Bool
    ) {
        guard !decelerate else { return }
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
        var ty = cell.convert(cell.bounds, to: self).origin.y
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
        handleView()?.isHidden = showHandle
    }

    private func handleView() -> UIView? {
        ((bgView as? ThemeBlurView)?.contentView ?? bgView)?.subviews.first
    }

    // MARK - Config
    
    private func configureUI() {
        backgroundColor = .clear
        clipsToBounds = false
        backgroundColor = UIColor.green.withAlpha(0.3)
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
        cv.alwaysBounceVertical = true
        cv.isPagingEnabled = true
        cv.showsVerticalScrollIndicator = false
        cv.topAdditionalTouchMargin = -Theme.padding
        addSubview(cv)
        return cv
    }

    private func newBackgroundView() -> UIView {
        let bgView = ThemeBlurView().round()
        insertSubview(bgView, at: 0)
        let pad = Theme.padding
        let frame = CGRect(zeroOrigin: .init(width: pad * 3, height: pad / 4))
        let handleView = UIView(frame: frame).rounded(frame.size.height.half)
        handleView.backgroundColor = .red // Theme.color.bgPrimary
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
