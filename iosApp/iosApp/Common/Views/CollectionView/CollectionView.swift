// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

protocol Progressable {
    func setProgress(_ progress: CGFloat)
}

@IBDesignable
class CollectionView: UICollectionView {
    /// View at the end of visible content
    var overscrollView: UIView? {
        didSet { didSetNewOverscrollView(overscrollView, old: oldValue)}
    }
    /// `overscrollView` top is at the end of the scroll area. `abovescrollView`
    /// bottom is at the end of scroll area. It is recommended to set
    /// `contentInset.bottom` to height of the `abovescrollView`
    @IBOutlet var abovescrollView: UIView? {
        didSet { didSetNewOverscrollView(abovescrollView, old: oldValue)}
    }
    /// View in on the top of content
    var topscrollView: UIView? {
        didSet { didSetNewOverscrollView(topscrollView, old: oldValue) }
    }
    /// When oversrolling `topscrollView` & `overscrollView` pinned to top.
    var pinTopScrollToTop: Bool = false
    /// When oversrolling `abovescrollView` & `overscrollView` pinned to bottom.
    var pinOverscrollToBottom: Bool = false
    /// Only valid with `TableGroupedFlowLayout` & `TableGroupedFlowLayout`
    var separatorInsets: UIEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0) {
        didSet { tableLayout()?.separatorInsets = separatorInsets }
    }
    /// Only valid with `TableGroupedFlowLayout` & `TableGroupedFlowLayout`
    var separatorColor: UIColor = .secondarySystemBackground {
        didSet { tableLayout()?.separatorColor = separatorColor }
    }
    /// Only valid with `TableGroupedFlowLayout` & `TableGroupedFlowLayout`
    var sectionBackgroundColor: UIColor = .systemBackground {
        didSet { tableLayout()?.sectionBackgroundColor = sectionBackgroundColor }
    }
    /// Only valid with `TableGroupedFlowLayout` & `TableGroupedFlowLayout`
    var sectionBorderColor: UIColor = .secondarySystemBackground {
        didSet { tableLayout()?.sectionBackgroundBorderColor = sectionBorderColor }
    }
    
    override init(
        frame: CGRect,
        collectionViewLayout layout: UICollectionViewLayout
    ) {
        super.init(frame: frame, collectionViewLayout: layout)
        backgroundView = CollectionBackgroundView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundView = CollectionBackgroundView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        repairViewsHierarchyIfNeeded()

        let pin = pinOverscrollToBottom

        layoutTopOverscrollView(topscrollView, pin: pinTopScrollToTop)
        layoutOverscrollView(overscrollView, pinToBottom: pin)
        layoutOverscrollView(abovescrollView, aboveLine: true, pinToBottom: pin)
    }

    private func layoutTopOverscrollView(_ view: UIView?, pin: Bool = false) {
        guard let view = view else { return }

        view.center.y = view.bounds.height * 0.5

        if pin && -contentOffset.y > safeAreaInsets.top {
            view.center.y += contentOffset.y + safeAreaInsets.top
        }
    }

    private func layoutOverscrollView(
        _ view: UIView?,
        aboveLine: Bool = false,
        pinToBottom: Bool = false
    ) {
        guard let view = view else { return }

        let adjInset = adjustedContentInset
        let safeInset = safeAreaInsets
        let btmOffsetAdj = safeInset.bottom == 34 ? 0 : safeInset.bottom
        var y: CGFloat = 0

        // Content size large enough to scroll
        if contentSize.height + adjInset.top + adjInset.bottom > bounds.height {
            y = contentSize.height + adjInset.bottom - btmOffsetAdj
        // Content does not fill entire view case (not scrolling)
        } else {
            y = bounds.maxY - contentOffset.y - adjInset.top - btmOffsetAdj
        }

        y = aboveLine ? y - view.bounds.height : y

        // Pinning to bottom or setting progress
        if pinToBottom || (view as? Progressable) != nil {
            let lim = safeAreaInsets.bottom == 34 ? 0 : safeAreaInsets.bottom
            let fullVisY = bounds.maxY - lim

            if let progressable = view as? Progressable {
                let progress = (fullVisY - y) / view.bounds.height
                progressable.setProgress(progress)
            }

            if pinToBottom {
                y = y + view.bounds.height < fullVisY
                    ? bounds.maxY - view.bounds.height - lim
                    : y
            }
        }

        view.frame = CGRect(
            origin: .init(x: bounds.midX - view.bounds.width / 2, y: y),
            size: CGSize(width: view.bounds.width, height: view.bounds.height)
        )

//        print(
//            "bounds.maxY: \(round(bounds.maxY)), y: \(round(y)), "
//            + "iA \(round(adjustedContentInset.top)) \(round(adjustedContentInset.bottom)), "
//            + "iC \(round(contentInset.top)) \(round(contentInset.bottom)), "
//            + "iS \(round(safeAreaInsets.top)) \(round(safeAreaInsets.bottom)), "
//            + "iM \(round(layoutMargins.top)) \(round(layoutMargins.bottom)), "
//            + "minY \(round(bounds.minY)) \(round(contentOffset.y)), "
//        )
    }

    private func didSetNewOverscrollView(_ new: UIView?, old: UIView?) {
        old?.removeFromSuperview()
        guard let view = new else { return }
        insertSubview(view, at: 0)
    }

    private func repairViewsHierarchyIfNeeded() {
        var baseIdx = backgroundView == nil ? 0 : 1
        
        if let view = overscrollView {
            if subviews[safe: baseIdx] != view {
                insertSubview(view, at: baseIdx)
            }
            baseIdx += 1
        }

        if let view = abovescrollView {
            if subviews[safe: baseIdx] != view {
                insertSubview(view, at: baseIdx)
            }
            baseIdx += 1
        }

        if let view = topscrollView, subviews[safe: baseIdx] != view {
            insertSubview(view, at: baseIdx)
        }
    }
    
    private func tableLayout() -> TableFlowLayout? {
        collectionViewLayout as? TableFlowLayout
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setNeedsLayout()
    }
}
