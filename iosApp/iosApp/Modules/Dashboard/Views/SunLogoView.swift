//
// Created by anon on 15/09/2023.
//

import UIKit

@IBDesignable
class SunLogoView: UIView, Progressable {
    @IBInspectable var sunImg: UIImage! { didSet { sunView.image = sunImg }}
    @IBInspectable var web3Img: UIImage! { didSet { web3View.image = web3Img }}
    @IBInspectable var threeImg: UIImage! {didSet { threeView.image = threeImg }}
    @IBInspectable var walletImg: UIImage! { didSet { walletView.image = walletImg }}
    @IBInspectable var lineImg: UIImage! { didSet { lineView.image = lineImg }}
    @IBInspectable var palmLImg: UIImage! { didSet { palmLView.image = palmLImg }}
    @IBInspectable var palmRImg: UIImage! { didSet { palmRView.image = palmRImg }}
    @IBInspectable var memeImg: UIImage! { didSet { memeView.image = memeImg }}
    private lazy var sunView = UIImageView(imgName: "sun_logo_sun")
    private lazy var web3View = UIImageView(imgName: "sun_logo_web3")
    private lazy var threeView = UIImageView(imgName: "sun_logo_three")
    private lazy var walletView = UIImageView(imgName: "sun_logo_wallet")
    private lazy var lineView = UIImageView(imgName: "sun_logo_line")
    private lazy var palmLView = UIImageView(imgName: "sun_logo_plalm_l")
    private lazy var palmRView = UIImageView(imgName: "sun_logo_plalm_r")
    private lazy var memeView = UIImageView(imgName: "sun_logo_pepe_analyst")
    private var prevProg: CGFloat = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let length = bounds.width
        let sunLength = length * 1.45
        sunView.bounds.size = .init(width: sunLength, height: sunLength)
        sunView.center = .init(x: bounds.midX, y: sunLength * 0.32)

        let web3ViewWidth = length * 0.675
        web3View.bounds.size = .init(
            width: web3ViewWidth,
            height: web3ViewWidth * 0.9046153846
        )
        web3View.center = .init(x: bounds.midX, y: bounds.midY * 1.075)

        let threeWidth = web3ViewWidth * 0.2276923077
        threeView.bounds.size = .init(width: threeWidth, height: threeWidth)
        threeView.center = .init(
            x: web3View.center.x * 1.45,
            y: web3View.center.y * 0.725
        )

        let walletWidth = web3ViewWidth * 0.79
        walletView.bounds.size = .init(
            width: walletWidth,
            height: walletWidth * 0.5182186235
        )
        walletView.center = .init(
            x: web3View.center.x,
            y: web3View.center.y * 1.38
        )

        let lineWidth = walletWidth * 0.9230769231
        lineView.bounds.size = .init(
            width: lineWidth,
            height: lineWidth * 0.2894736842
        )
        lineView.center = .init(
            x: walletView.center.x,
            y: walletView.frame.maxY * 0.925
        )

        let palmLWidth = web3ViewWidth * 0.33 // 0.241025641
        palmLView.bounds.size = .init(
            width: palmLWidth,
            height: palmLWidth * 1.414893617
        )
        palmLView.center = .init(
            x: web3View.center.x * 0.43,
            y: web3View.center.y * 1.175
        )

        let palmRWidth = web3ViewWidth * 0.42 // 0.3025641026
        palmRView.bounds.size = .init(
            width: palmRWidth,
            height: palmRWidth * 1.4533898305
        )
        palmRView.center = .init(
            x: web3View.center.x * 1.425,
            y: web3View.center.y * 1.075
        )

        let memeWidth = web3ViewWidth * 0.35
        memeView.bounds.size = .init(width: memeWidth, height: memeWidth)
        memeView.center = .init(
            x: web3View.center.x * 0.9225,
            y: web3View.center.y * 0.4425
        )
    }

    func setProgress(_ progress: CGFloat) {
        if ThemeVanilla.isCurrent() {
            alpha = (progress - 0.2) / 0.2
        }
        let length = bounds.width
        let invProg = 1 - progress

        memeView.alpha = min(0.9, max(0.1, progress)) / 0.8
        memeView.transform = CGAffineTransform(
            translationX: 0,
            y: invProg * length * 0.02
        )
        palmLView.transform = CGAffineTransform(
            rotationAngle: invProg * Double.pi * 0.05 - 0.05
        )
        palmRView.transform = CGAffineTransform(
            rotationAngle: invProg * Double.pi * -0.05 + 0.05
        )

        let threeMltp = (progress + 4) / 6
        let walletMltp = (progress + 6) / 8
        let web3Mltp = (progress + 10) / 12
        let trans = invProg * length * 0.03
        threeView.transform = CGAffineTransformTranslate(
            CGAffineTransform(scaleX: threeMltp,y: threeMltp),
            -trans,
            trans
        )
        walletView.transform = CGAffineTransform(scaleX: walletMltp,y: walletMltp)
        lineView.transform = walletView.transform
        web3View.transform = CGAffineTransform(scaleX: web3Mltp,y: web3Mltp)
        prevProg = progress
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        configureUI()
        setNeedsLayout()
    }

    private func configureUI() {
        guard sunView.superview == nil else { return }
        [
            sunView, palmLView, palmRView, memeView, web3View, walletView,
            lineView, threeView
        ].forEach {
            $0.contentMode = .scaleAspectFit
            addSubview($0)
        }
        clipsToBounds = false
    }

    enum Constant {
        static let memeAnim: CGFloat = 0.6
    }
}
