// Created by web3d3v on 15/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

class EdgeCardsController: UIViewController {

    private(set) var master: UIViewController?
    private(set) var topCard: UIViewController?
    private(set) var bottomCard: UIViewController?
    
    private(set) var displayMode: DisplayMode = .master

    var cardNavigationEnabled: Bool = true

    private var masterContainer: UIView = .init()
    private var topCardContainer: UIView = .init()
    private var bottomCardContainer: UIView = .init()
    private var containers: [UIView] {
        [masterContainer, topCardContainer, bottomCardContainer]
    }

    private var swipingToMode: DisplayMode = .overview
    private var swipeProgress: CGFloat = 0
    private var tapRecognizers: [UITapGestureRecognizer] = []
    private var panRecognizer: UIPanGestureRecognizer!
    private var edgeRecognizer: UIScreenEdgePanGestureRecognizer!

    init(
        master: UIViewController?,
        topCard: UIViewController?,
        bottomCard: UIViewController
    ) {
        super.init(nibName: nil, bundle: nil)
        self.master = master
        self.topCard = topCard
        self.bottomCard = bottomCard
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    func setMaster(vc: UIViewController) {
        let fromVc = vc == master ? nil : master
        setViewController(vc: vc, fromVc: fromVc, toContainer: masterContainer)
        master = vc
    }
    
    func setTopCard(vc: UIViewController) {
        let fromVc = vc == topCard ? nil : topCard
        setViewController(vc: vc, fromVc: fromVc, toContainer: topCardContainer)
        topCard = vc
    }
    
    func setBottomCard(vc: UIViewController) {
        let fromVc = vc == bottomCard ? nil : bottomCard
        setViewController(vc: vc, fromVc: fromVc, toContainer: bottomCardContainer)
        bottomCard = vc
    }

    func setDisplayMode(_ mode: DisplayMode, animated: Bool = false) {
        guard animated else {
            setupForDisplayMode(mode)
            return
        }

        UIView.springAnimate(
            damping: mode.isFullScreen() ? 0.9 : 0.8,
            animations: { self.setupForDisplayMode(mode) }
        )
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layout()
    }
    
    override func viewDidLayoutSubviews() {
        layout()
        super.viewDidLayoutSubviews()
    }

    @objc func edgePanned(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            swipingToMode = .overview
            swipeProgress = 0
            // TODO: Play haptics
        case .changed:
            let translation = recognizer.translation(in: view)
            swipeProgress = translation.x / view.bounds.width
            layout()
        case .ended, .failed:
            UIView.springAnimate(
                0.5,
                velocity: recognizer.velocity(in: view).x / view.bounds.width,
                animations: {
                    self.swipeProgress = 0.85
                    self.layout()
                },
                completion: { _ in
                    self.displayMode = self.swipingToMode
                    self.swipeProgress = 0
                }
            )
        default:
            ()
        }
    }

    @objc func panned(_ recognizer: UIPanGestureRecognizer) {

    }


    @objc func tapMaster(_ recognizer: UITapGestureRecognizer?) {
        setDisplayMode(.master, animated: true)
    }

    @objc func tapTopCard(_ recognizer: UITapGestureRecognizer?) {
        setDisplayMode(.topCard, animated: true)
    }

    @objc func tapBottomCard(_ recognizer: UITapGestureRecognizer?) {
        setDisplayMode(.bottomCard, animated: true)
    }
}

// MARK: - Layout

private extension EdgeCardsController {

    func setupForDisplayMode(_ mode: DisplayMode) {
        (swipingToMode, displayMode) = (mode, mode)
        switch mode {
        case .overview:
            swipeProgress = 0.85
        default:
            ()
        }
        layout()
    }

    private func layout() {
        containers.forEach {
            $0.bounds = view.bounds
            if [topCardContainer, bottomCardContainer].contains($0) {
                var bounds = view.bounds
                bounds.size.width = view.bounds.width * 0.95
                $0.bounds = bounds
                $0.center.x = bounds.width / 2
            }
            $0.subviews.first?.bounds = $0.bounds
            applyShadows($0)
        }

        switch swipingToMode {
        case .overview:
            layoutToOverview()
        case .bottomCard:
            layoutToBottom()
        case .topCard:
            layoutToTop()
        case .master:
            layoutToMaster()
        }
    }

    private func layoutToOverview() {
        let pct = swipeProgress
        masterContainer.transform = CGAffineTransform(
            translationX: max(0, view.bounds.width * pct),
            y: 0
        )

        var transX = view.bounds.width * 0.5 * pct
        var transS = 1 - 0.025 * pct

        topCardContainer.transform = CGAffineTransform(scaleX: transS, y: transS)
                .concatenating(CGAffineTransform(translationX: transX, y: 0))

        transX = view.bounds.width * max(0, 0.5 * pct - 0.85)
        transS = 1 - 0.05 * pct

        bottomCardContainer.transform = CGAffineTransform(scaleX: transS, y: transS)
                .concatenating(CGAffineTransform(translationX: transX, y: 0))
    }

    func layoutToBottom() {
        masterContainer.transform = CGAffineTransform(
            translationX: 0.85 * view.bounds.width,
            y: 0
        )

        topCardContainer.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
                .concatenating(CGAffineTransform(translationX:  view.bounds.width * 0.75, y: 0))

        bottomCardContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }

    func layoutToTop() {
        masterContainer.transform = CGAffineTransform(
            translationX: 0.85 * view.bounds.width,
            y: 0
        )

        topCardContainer.transform = CGAffineTransform(scaleX: 0.975, y: 0.975)
                .concatenating(CGAffineTransform(translationX:  view.bounds.width * 0.1, y: 0))

        bottomCardContainer.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
    }

    func layoutToMaster() {
        containers.forEach {
            $0.transform = .identity
            applyShadows($0, mode: .master)
        }
    }

    func applyShadows(_ container: UIView) {
        if swipeProgress == 0 || swipeProgress > 0.2 {
            applyShadows(container, mode: swipingToMode)
        } else {
            let progress = swipingToMode.isFullScreen()
                ? 1 / swipeProgress
                : swipeProgress
            applyShadows(
                container,
                radius: Constant.cornerRadius * progress * 5,
                opacity: Float(progress * 5)
            )
        }
    }

    private func applyShadows(_ container: UIView, mode: DisplayMode) {
        applyShadows(
            container,
            radius: mode.isFullScreen() ? 0 : Constant.cornerRadius,
            opacity: mode.isFullScreen() ? 0 : 1
        )
    }

    private func applyShadows(
        _ container: UIView,
        radius: CGFloat,
        opacity: Float
    ) {
        container.layer.cornerRadius = radius
        container.layer.shadowOpacity = opacity
        container.layer.shadowRadius = Constant.shadowRadius
        container.layer.shadowColor = Constant.shadowColor
        container.layer.shadowOffset = .zero
        container.layer.shadowPath = UIBezierPath(
            roundedRect: container.bounds,
            cornerRadius: container.layer.cornerRadius
        ).cgPath

        container.subviews.first?.layer.masksToBounds = true
        container.subviews.first?.layer.cornerRadius = container.layer.cornerRadius
    }

}

// MARK: - UI utilities

private extension EdgeCardsController {

    func configureUI() {
        containers.forEach {
            $0.frame = view.bounds
        }

        view.addSubview(bottomCardContainer)
        view.addSubview(topCardContainer)
        view.addSubview(masterContainer)

        if let bottomCard = self.bottomCard {
            setBottomCard(vc: bottomCard)
        }

        if let topCard = self.topCard {
            setTopCard(vc: topCard)
        }

        if let master = self.master {
            setMaster(vc: master)
        }

        setupGestureRecognizers()
    }

    private func setViewController(
        vc: UIViewController?,
        fromVc: UIViewController?,
        toContainer: UIView
    ) {
        guard isViewLoaded else {
            return
        }

        guard let vc = vc else {
            fromVc?.willMove(toParent: nil)
            fromVc?.view.removeFromSuperview()
            fromVc?.removeFromParent()
            return
        }

        fromVc?.willMove(toParent: nil)
        addChild(vc)
        vc.view.frame = toContainer.bounds
        toContainer.addSubview(vc.view)
        vc.didMove(toParent: self)
        fromVc?.view.removeFromSuperview()
        fromVc?.removeFromParent()
    }
}

// MARK: - Recognizers

extension EdgeCardsController: UIGestureRecognizerDelegate {

    func setupGestureRecognizers() {
        let tapMasterCard = UITapGestureRecognizer(
            target: self,
            action: #selector(tapMaster(_:))
        )
        let tapTopCard = UITapGestureRecognizer(
            target: self,
            action: #selector(tapTopCard(_:))
        )
        let tapBottomCard = UITapGestureRecognizer(
            target: self,
            action: #selector(tapBottomCard(_:))
        )

        tapRecognizers = [tapMasterCard, tapMasterCard, tapBottomCard]
        tapRecognizers.forEach { $0.delegate = self }
        masterContainer.addGestureRecognizer(tapMasterCard)
        topCardContainer.addGestureRecognizer(tapTopCard)
        bottomCardContainer.addGestureRecognizer(tapBottomCard)

        edgeRecognizer = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(edgePanned(_:))
        )
        edgeRecognizer.edges = .left
        view.addGestureRecognizer(edgeRecognizer)

        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panned(_:)))
//        view.addGestureRecognizer(panRecognizer)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        return true
    }
}


// MARK: - DisplayMode

extension EdgeCardsController {

    enum DisplayMode {
        case master
        case overview
        case topCard
        case bottomCard

        func isFullScreen() -> Bool {
            switch self {
            case .master: return true
            default: return false
            }
        }
    }
}

// MARK: - EdgeCardsController UIViewController extension

/// `UIViewController` extension that adds `EdgeCardsController` support similar
/// to `UINavigationController` or `UISplitViewController`. Also adds navigation
/// action `showDrawerViewController(_:sender:)` akin to
/// `showDetailViewController(_:sender:)`
extension UIViewController {

    /// If this view controller has been pushed onto a drawer controller, return it.
    var edgeCardsController: EdgeCardsController? {
        return findParentDrawer(self)
    }
    
    private func findParentDrawer( _ vc: UIViewController?) -> EdgeCardsController? {
        // Look for `EdgeCardsController` in parents
        if let parent = vc?.parent {
            return (parent as? EdgeCardsController) ?? parent.edgeCardsController
        }
        // Check wether presenting is `EdgeCardsController`
        if let drawer = vc?.presentingViewController as? EdgeCardsController {
            return drawer
        }
        // Look for `EdgeCardsController` in presenting VC parents
        return vc?.presentingViewController?.edgeCardsController
    }
}

// MARK: - Constant

private extension EdgeCardsController {

    enum Constant {
        static let cornerRadius: CGFloat = 28
        static let shadowRadius: CGFloat = 8
        static let shadowColor = UIColor.black.withAlphaComponent(0.5).cgColor
    }
}
