// Created by web3d3v on 07/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardBackgroundView: BackgroundView {
    private lazy var topPalm = UIImageView(imgName: "dashboard-palm")
    private lazy var btmSun = UIImageView(imgName: "overscroll_sun")
    private lazy var btmLogo = UIImageView(imgName: "overscroll_logo")
    private lazy var btmMeme = UIImageView(imgName: "overscroll_meme")

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override func configureUI() {
        super.configureUI()
        [btmMeme, btmLogo, btmSun, topPalm].forEach {
            insertSubview($0, aboveSubview: gradientView)
            $0.isHidden = Theme as? ThemeVanilla != nil
        }
    }

    func layoutForCollectionView(_ cv: UICollectionView) {
        let cvBounds = cv.bounds
        let offset = convert(cv.contentOffset, from: cv.superview)
        topPalm.center = CGPoint(
            x: cvBounds.maxX - topPalm.bounds.width * 0.45,
            y: min(cv.safeAreaInsets.top, -offset.y) + topPalm.bounds.height * 0.15
        )
        let sunSize = btmSun.image?.size ?? .zero
        let logoSize = btmLogo.image?.size ?? .zero
        let memeSize = btmMeme.image?.size ?? .zero
        let maxY = bounds.maxY - cv.adjustedContentInset.top + Theme.padding
        let scrollY = cv.contentSize.height +
            Theme.padding +
            cv.adjustedContentInset.bottom -
            cv.adjustedContentInset.top -
            cv.contentOffset.y
        let y = max(scrollY, maxY)
        
        btmLogo.center = CGPoint(x: bounds.midX, y: y - logoSize.height.half)
        btmMeme.center = CGPoint(x: bounds.midX + 9, y: y - sunSize.height * 0.7)
        btmSun.frame = CGRect(
            center: CGPoint(x: bounds.midX, y: y - sunSize.height.half),
            size: sunSize
        )
    }
}
