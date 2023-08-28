//
// Created by anon on 28/08/2023.
//

import UIKit

class LogoAnimView: UIView {
    private lazy var logo = UIImageView(image: UIImage(named: "logo_complete"))
    private weak var sun: UIImageView? = nil
    private weak var web3: UIImageView? = nil
    private weak var badge: UIImageView? = nil
    private weak var wallet: UIImageView? = nil
    private weak var degen: UIImageView? = nil

    private var animId: Int = 0

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
        [logo, sun, web3, badge].forEach {
            $0?.bounds = bounds
            $0?.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
        let walletSize = CGSize(
                width: bounds.width * 0.641025641,
                height: bounds.height * 0.3076923077
        )
        wallet?.bounds = CGRect(origin: .zero, size: walletSize)
        wallet?.center = CGPoint(
                x: bounds.width * 0.1852564103 + walletSize.width / 2.0,
                y: bounds.height * 0.6506410256 + walletSize.height / 2.0
        )
        let degenSize = CGSize(
                width: bounds.width * 0.3205128205,
                height: bounds.height * 0.09615384615
        )
        degen?.bounds = CGRect(origin: .zero, size: degenSize)
        degen?.center = CGPoint(
                x: bounds.width * 0.483974359 + degenSize.width / 2.0,
                y: bounds.height * 0.8608974359 + degenSize.height / 2.0
        )
    }

    func animate() {
        animId += 1
        let currAnimId = animId
        setupAnimationViews()

        [sun, web3, badge].forEach {
            $0?.transform = CGAffineTransformMakeScale(4, 4)
        }

        let animViews = [sun, web3, badge, wallet, degen]
        animViews.forEach { $0?.alpha = 0 }

        UIView.springAnimate(
                1,
                delay: 0,
                animations: { [weak self] in self?.sun?.transform = .identity }
        )
        UIView.springAnimate(
                1,
                delay: 0.15,
                animations: { [weak self] in self?.web3?.transform = .identity }
        )
        UIView.springAnimate(
                1,
                delay: 0.3,
                animations: { [weak self] in self?.badge?.transform = .identity }
        )
        UIView.springAnimate(
                0.01,
                animations: { [weak self] in self?.sun?.alpha = 1 }
        )
        UIView.springAnimate(
                0.01,
                delay: 0.15,
                animations: { [weak self] in self?.web3?.alpha = 1 }
        )
        UIView.springAnimate(
                0.01,
                delay: 0.3,
                animations: { [weak self] in self?.badge?.alpha = 1 }
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            guard currAnimId == self?.animId ?? 0 else { return }
            self?.wallet?.image = UIImage(named: "logo_anim_wallet_line_108292")
            self?.wallet?.alpha = 1
            self?.wallet?.image = self?.walletImage()
            self?.wallet?.startAnimating()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { [weak self] in
            guard currAnimId == self?.animId ?? 0 else { return }
            self?.wallet?.image = UIImage(named: "logo_anim_wallet_line_108292")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) { [weak self] in
            guard currAnimId == self?.animId ?? 0 else { return }
            self?.degen?.image = UIImage(named: "logo_anim_degens_86634")
            self?.degen?.alpha = 1
            self?.degen?.image = self?.degensImage()
            self?.degen?.startAnimating()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.7) { [weak self] in
            guard currAnimId == self?.animId ?? 0 else { return }
            self?.degen?.image = UIImage(named: "logo_anim_degens_86634")
        }
    }

    private func configureUI() {
        addSubview(logo)
//        let tap = UITapGestureRecognizer(
//            target: self,
//            action: #selector(tapAction(_:))
//        )
//        addGestureRecognizer(tap)
    }
//
//    @objc func tapAction(_ sender: Any!) {
//        animate()
//    }

    private func setupAnimationViews() {
        [sun, web3, badge, wallet, degen].forEach { $0?.removeFromSuperview() }

        let animViews = [
            UIImageView(image: UIImage(named: "logo_sun")),
            UIImageView(image: UIImage(named: "logo_web3")),
            UIImageView(image: UIImage(named: "logo_three")),
            UIImageView(image: walletImage()),
            UIImageView(image: degensImage()),
        ]

        [animViews[3], animViews[4]].forEach {
            $0.animationRepeatCount = 0
            $0.stopAnimating()
        }

        animViews.forEach {
            addSubview($0)
            $0.contentMode = .scaleAspectFit
            $0.backgroundColor = .clear
        }

        sun = animViews[0]
        web3 = animViews[1]
        badge = animViews[2]
        wallet = animViews[3]
        degen = animViews[4]

        logo.backgroundColor = .clear
        logo.isHidden = true
    }

    private func degensImage() -> UIImage {
        UIImage.animatedImage(
                with: (86564..<86635).map {
                    UIImage(named: "logo_anim_degens_\($0)")!
                },
                duration: 1.5
        )!
    }

    private func walletImage() -> UIImage {
        UIImage.animatedImage(
                with: (108056..<108293).map {
                    UIImage(named: "logo_anim_wallet_line_\($0)")!
                },
                duration: 1.5
        )!
    }
}

