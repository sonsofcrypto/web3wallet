// Created by web3d3v on 19/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

final class DashboardWalletCell: CollectionViewCell {
    @IBOutlet weak var contentStack: UIStackView!
    @IBOutlet weak var topContentStack: UIStackView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var fiatPriceLabel: UILabel!
    @IBOutlet weak var pctChangeLabel: UILabel!
    @IBOutlet weak var charView: CandlesView!
    @IBOutlet weak var fiatBalanceLabel: UILabel!
    @IBOutlet weak var cryptoBalanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        backgroundView = DashboardWalletCellBackgroundView()
        imageView.layer.cornerRadius = imageView.frame.size.width * 0.5
        imageView.backgroundColor = UIColor(hexString: "3461BE")!
        fiatPriceLabel.font = Theme.font.dashboardTVBalance
        fiatPriceLabel.textColor = Theme.colour.labelPrimary
        currencyLabel.font = Theme.font.dashboardTVSymbol
        currencyLabel.textColor = Theme.colour.labelPrimary
        pctChangeLabel.font = Theme.font.dashboardTVPct
        pctChangeLabel.textColor = Theme.colour.priceUp
        fiatBalanceLabel.font = Theme.font.dashboardTVTokenBalance
        fiatBalanceLabel.textColor = Theme.colour.dashboardTVCryptoBallance
        cryptoBalanceLabel.font = Theme.font.dashboardTVTokenBalance
        cryptoBalanceLabel.textColor = Theme.colour.dashboardTVCryptoBallance
        fiatBalanceLabel.isHidden = true
//        contentStack.setCustomSpacing(0, after: fiatBalanceLabel)

    }

    override func prepareForReuse() {
        super.prepareForReuse()
        layer.transform = CATransform3DIdentity
        layer.removeAllAnimations()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

extension DashboardWalletCell {

    func update(with viewModel: DashboardViewModel.Wallet?) -> Self {
        guard let viewModel = viewModel else {
            return self
        }
        
        imageView.image = viewModel.imageName.pngImage
        currencyLabel.text = viewModel.ticker
        fiatPriceLabel.text = viewModel.fiatPrice
        pctChangeLabel.text = viewModel.pctChange
        pctChangeLabel.textColor = viewModel.priceUp
            ? Theme.colour.priceUp
            : Theme.colour.priceDown
        pctChangeLabel.layer.shadowColor = pctChangeLabel.textColor.cgColor
        charView.update(viewModel.candles)
        cryptoBalanceLabel.text = viewModel.cryptoBalance

        let colors = viewModel.colors
        let top = UIColor(hexString: colors.first ?? "#FFFFFF")!
        let btm = UIColor(hexString: colors.last ?? colors.first ?? "#000000")!
        (backgroundView as? DashboardWalletCellBackgroundView)?.strokeColors = [top, btm]

        return self
    }
}

// MARK: - DashboardWalletCellBackgroundView

class DashboardWalletCellBackgroundView: UIView {

    var strokeColors: [UIColor] = [] {
        didSet {
            if strokeColors.isEmpty {
                strokeGradient.colors = [.white, .white]
            } else {
                strokeGradient.colors = strokeColors
            }
        }
    }

    private lazy var strokeGradient: GradientView = {
        let view = GradientView()
        view.colors = [.white, .white]
        view.direction = .custom(CGPoint(x: 0, y: 0), CGPoint(x: 1, y: 1))
        insertSubview(view, at: 0)
        return view
    }()

    private lazy var fillGradient: GradientView = {
        let view = GradientView()
        view.colors = [UIColor(hexString: "3461BE")!, UIColor(hexString: "223E7B")!]
        view.direction = .custom(CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 1))
        insertSubview(view, at: 1)
        view.layer.cornerRadius = Theme.constant.cornerRadius
        view.layer.maskedCorners = .all
        return view
    }()

    private lazy var noise: UIImageView = {
        let view = UIImageView(image: UIImage(named: "tv_noise"))
        insertSubview(view, at: 2)
        return view
    }()

    private lazy var highlight: UIImageView = {
        let view = UIImageView(image: UIImage(named: "tv_highlight"))
        view.contentMode = .scaleAspectFill
        insertSubview(view, at: 2)
        return view
    }()

    private lazy var highlightBtm: UIImageView = {
        let view = UIImageView(image: UIImage(named: "tv_highlight_btm"))
        view.contentMode = .scaleAspectFill
        insertSubview(view, at: 2)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configUI()
    }

    func configUI() {
        clipsToBounds = true
        layer.cornerRadius = Theme.constant.cornerRadius
        layer.maskedCorners = CACornerMask.all
//        noise.alpha = 0.5
//        [highlight, highlightBtm].forEach { $0.alpha = 0.5 }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        strokeGradient.frame = bounds
        fillGradient.frame = bounds.insetBy(dx: 2, dy: 2)
        noise.frame = bounds

        let ratio = highlight.image?.heightWidthwRatio() ?? 0
        var highlightBounds = bounds
        highlightBounds.size.width = bounds.width
        highlightBounds.size.height = bounds.width * ratio
        highlight.frame = highlightBounds

        highlightBounds.origin.y = bounds.height - highlightBounds.height
        highlightBtm.frame = highlightBounds
    }
}
