// Created by web3d3v on 07/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardBackgroundView: UIScrollView {
    private lazy var gradientView = ThemeGradientView(frame: bounds)
    private lazy var topPalm = UIImageView(named: "dashboard-palm")
    private lazy var btmSun = UIImageView(named: "overscroll_sun")
    private lazy var btmLogo = UIImageView(named: "overscroll_logo")
    private lazy var btmMeme = UIImageView(named: "overscroll_meme")

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    func configureUI() {
        [gradientView, topPalm, btmSun, btmLogo, btmMeme].forEach {
            addSubview($0)
            $0.isHidden = Theme.type.isThemeIOS
        }
        isUserInteractionEnabled = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientView.frame = CGRect(zeroOrigin: contentSize)
        topPalm.center = CGPoint(
            x: bounds.maxX - topPalm.bounds.width * 0.45,
            y: topPalm.bounds.height * 0.15
        )
        let h = contentSize.height - adjustedContentInset.bottom
        let sunSize = btmSun.image?.size ?? .zero
        let logoSize = btmLogo.image?.size ?? .zero
        let memeSize = btmMeme.image?.size ?? .zero
        let btmCenter = CGPoint(x: bounds.midX, y: h - sunSize.height.half)
        let logoCenter = CGPoint(x: bounds.midX, y: h - logoSize.height.half)
        let memeCenter = CGPoint(x: bounds.midX + 9, y: h - sunSize.height * 0.7)
        btmSun.frame = CGRect(center: btmCenter, size: sunSize)
        btmLogo.frame = CGRect(center: logoCenter, size: logoSize)
        btmMeme.frame = CGRect(center: memeCenter, size: memeSize)
    }

    func layoutForCollectionView(_ cv: UICollectionView) {
        contentSize = cv.contentSize.sizeAddingToHeight(cv.contentInset.bottom)
        let maxY = max(0, contentSize.height - cv.bounds.height)
        contentOffset = CGPoint(
            x: cv.contentOffset.x,
            y: min(maxY, max(0, cv.contentOffset.y))
        )
    }
}
