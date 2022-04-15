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
    private var oppositeDirectionMode: DisplayMode = .master
    private var initVelocityX: CGFloat = 0
    private var velocitySignMltp: CGFloat = 1
    private var swipeProgress: CGFloat = 1
    private var swipeFromMaster: CGFloat = 1
    private var swipeToMaster: CGFloat = 1
    private var swipeFromTop: CGFloat = 1
    private var swipeToTop: CGFloat = 1
    private var swipeFromBottom: CGFloat = 1
    private var swipeToBottom: CGFloat = 1
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
        guard mode != .masterOnboardAnim else {
            onboardAnimToMaster()
            return
        }

        guard animated else {
            setupForDisplayMode(mode)
            return
        }

        UIView.springAnimate(
            damping: mode.isFullScreen()
                ? Constant.displayModeLongAnim
                : Constant.displayModeShortAnim,
            animations: { self.setupForDisplayMode(mode) }
        )
    }

    @objc func edgePanned(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        panned(recognizer)
    }

    @objc func panned(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            let velocityX = recognizer.velocity(in: view).x
            initVelocityX = velocityX
            setupSwipeToFroms(displayMode, velocityX: velocityX)
            swipeProgress = 0
        case .changed:
            let velocityX = recognizer.velocity(in: view).x
            let translation = recognizer.translation(in: view)
            swipeProgress = translation.x / view.bounds.width
            layout()
        case .ended, .failed:
            let velocityX = recognizer.velocity(in: view).x
            let revert = didChangeSign(start: initVelocityX, end: velocityX)
            let duration = revert ? Constant.shortAnim : Constant.longAnim
            let mode = revert ? oppositeDirectionMode : swipingToMode
            swipeProgress = 1 * velocitySignMltp
            UIView.springAnimate(
                duration,
                velocity: recognizer.velocity(in: view).x / view.bounds.width,
                animations: { self.setupForDisplayMode(mode)}
            )
        default:
            ()
        }
    }

    func didChangeSign(start: CGFloat, end: CGFloat) -> Bool {
        if (start >= 0 && end >= 0) || (start < 0 && end < 0) {
            return false
        }
        return true
    }

    @objc func tapMaster(_ recognizer: UITapGestureRecognizer?) {
        setDisplayMode(.master, animated: true)
    }

    @objc func tapTopCard(_ recognizer: UITapGestureRecognizer?) {
        setDisplayMode(.overviewTopCard, animated: true)
    }

    @objc func tapBottomCard(_ recognizer: UITapGestureRecognizer?) {
        setDisplayMode(.overviewBottomCard, animated: true)
    }
}

// MARK: - Layout

private extension EdgeCardsController {

    func setupForDisplayMode(_ mode: DisplayMode) {
        (swipingToMode, displayMode) = (mode, mode)
        setupToFromSwipeForFinalPosition(mode)
        setupRecognizers(for: mode)
        layout()
    }

    func layout() {
        containers.forEach {
           ($0.bounds, $0.center) = (view.bounds, view.bounds.midXY)

            if [topCardContainer, bottomCardContainer].contains($0)
               && !displayMode.isNonMasterFullScreen() {
                $0.bounds.size.width = view.bounds.width * Constant.contScl
                $0.center = $0.bounds.midXY
            }

            $0.subviews.first?.bounds = $0.bounds
            $0.subviews.first?.center = $0.bounds.midXY
            applyShadows($0)
        }
        switch swipingToMode {
        case .overview, .overviewTopCard, .overviewBottomCard:
            layoutToOverview()
        case .master:
            layoutToMaster()
        case .topCard:
            layoutToTop()
        case .bottomCard:
            layoutToBottom()
        case .masterOnboardAnim:
            layoutToMasterOnboardAnim()
        }
    }

    func setupSwipeToFroms(_ mode: DisplayMode, velocityX: CGFloat) {
        switch mode {
        case .overview:
            if velocityX >= 0 {
                (swipeFromMaster, swipeToMaster) = (CT.mstrOv, CT.mstrMax)
                (swipeFromTop, swipeToTop) = (CT.topOv, CT.topMax)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                swipingToMode = .overviewBottomCard
                oppositeDirectionMode = .master
                velocitySignMltp = 1
            } else {
                (swipeFromMaster, swipeToMaster) = (CT.mstrOv, CT.mstrMax)
                (swipeFromTop, swipeToTop) = (CT.topOv, CT.topMin)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                swipingToMode = .overviewTopCard
                oppositeDirectionMode = .overviewBottomCard
                velocitySignMltp = -1
            }
        case .overviewTopCard:
            if velocityX >= 0 {
                (swipeFromMaster, swipeToMaster) = (CT.mstrMax, CT.mstrMax)
                (swipeFromTop, swipeToTop) = (CT.topMin, CT.topMax)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                swipingToMode = .overviewBottomCard
                oppositeDirectionMode = .overviewTopCard
                velocitySignMltp = 1
            } else {
                (swipeFromMaster, swipeToMaster) = (CT.mstrMax, 0)
                (swipeFromTop, swipeToTop) = (CT.topMin, 0)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                swipingToMode = .master
                oppositeDirectionMode = .overviewTopCard
                velocitySignMltp = -1
            }
        case .overviewBottomCard:
            if velocityX >= 0 {
                (swipeFromMaster, swipeToMaster) = (CT.mstrMax, CT.mstrMax)
                (swipeFromTop, swipeToTop) = (CT.topMax, CT.topMax)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                velocitySignMltp = -1
                swipingToMode = .overviewBottomCard
                oppositeDirectionMode = .overviewTopCard
            } else {
                (swipeFromMaster, swipeToMaster) = (CT.mstrMax, CT.mstrMax)
                (swipeFromTop, swipeToTop) = (CT.topMax, CT.topMin)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                velocitySignMltp = -1
                swipingToMode = .overviewTopCard
                oppositeDirectionMode = .overviewBottomCard
            }
        case .master:
            if velocityX >= 0 {
                (swipeFromMaster, swipeToMaster) = (0, CT.mstrMax)
                (swipeFromTop, swipeToTop) = (0, CT.topOv)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                velocitySignMltp = 1
                swipingToMode = .overview
                oppositeDirectionMode = .master
            } else {
                (swipeFromMaster, swipeToMaster) = (0, 0)
                (swipeFromTop, swipeToTop) = (0, 0)
                (swipeFromBottom, swipeToBottom) = (0, 0)
                swipingToMode = .master
                oppositeDirectionMode = .overview
            }
        default:
            (swipeFromMaster, swipeToMaster) = (0, 0)
            (swipeFromTop, swipeToTop) = (0, 0)
            (swipeFromBottom, swipeToBottom) = (0, 0)
        }
    }

    func setupToFromSwipeForFinalPosition(_ mode: DisplayMode) {
        velocitySignMltp = 1
        swipeProgress = 1
        switch mode {
        case .overview:
            (swipeFromMaster, swipeToMaster) = (CT.mstrOv, CT.mstrOv)
            (swipeFromTop, swipeToTop) = (CT.topOv, CT.topOv)
            (swipeFromBottom, swipeToBottom) = (0, 0)
        case .overviewTopCard:
            (swipeFromMaster, swipeToMaster) = (CT.mstrMax, CT.mstrMax)
            (swipeFromTop, swipeToTop) = (CT.topMin, CT.topMin)
            (swipeFromBottom, swipeToBottom) = (0, 0)
        case .overviewBottomCard:
            (swipeFromMaster, swipeToMaster) = (CT.mstrMax, CT.mstrMax)
            (swipeFromTop, swipeToTop) = (CT.topMax, CT.topMax)
            (swipeFromBottom, swipeToBottom) = (0, 0)
        default:
            (swipeFromMaster, swipeToMaster) = (0, 0)
            (swipeFromTop, swipeToTop) = (0, 0)
            (swipeFromBottom, swipeToBottom) = (0, 0)
        }
    }

    func layoutToOverview() {
        let pct = swipeProgress * velocitySignMltp
        let width = view.bounds.width
        var mltp = pctVal(from: swipeFromMaster, to: swipeToMaster, pct: pct)
        var transX = mltp * width
        masterContainer.transform = CGAffineTransform(translationX: transX, y: 0)

        var (ts, bs) = (Constant.cardScl, Constant.contScl)
        if sizeChangingTransition() {
            let prog = swipingToMode == .master ? 1 - pct : pct
            ts = pctVal(from: 1, to: ts, pct: prog)
            bs = pctVal(from: 1, to: bs, pct: prog)
        }

        mltp = pctVal(from: swipeFromTop, to: swipeToTop, pct: pct)
        transX =  width * mltp - (1 - ts) / 2  * width
        topCardContainer.transform = CGAffineTransform(scaleX: ts, y: ts)
            .concatenating(CGAffineTransform(translationX: transX, y: 0))

        transX =  -(1 - bs) / 2 * width
        bottomCardContainer.transform = CGAffineTransform(scaleX: bs, y: bs)
            .concatenating(CGAffineTransform(translationX: transX, y: 0))
    }

    func layoutToMaster() {
        layoutToOverview()
        if abs(swipeProgress) == 1 {
            containers.forEach { $0.transform = .identity }
        }
    }

    func layoutToTop() {
        containers.forEach { $0.transform = .identity}
        let transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        masterContainer.transform = transform
    }

    func layoutToBottom() {
        let transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        containers.forEach {
            $0.transform = $0 == bottomCardContainer ? .identity : transform
        }
    }

    func layoutToMasterOnboardAnim() {
        let transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
        containers.forEach {
            $0.transform = $0 == bottomCardContainer ? .identity : transform
        }
    }

    func applyShadows(_ container: UIView) {
        guard sizeChangingTransition() else {
            applyShadows(
                container,
                radius: displayMode.isFullScreen() ? 0 : Constant.cornerRadius,
                opacity: displayMode.isFullScreen() ? 0 : 1
            )
            return
        }

        let progress = swipingToMode.isFullScreen()
            ? 1 / abs(swipeProgress * 5)
            : swipeProgress * 5

        applyShadows(
            container,
            radius: Constant.cornerRadius * min(1, progress),
            opacity: Float(min(1, progress))
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

        let firstSubView = container.subviews.first
        firstSubView?.layer.masksToBounds = true
        firstSubView?.layer.cornerRadius = container.layer.cornerRadius
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

    func sizeChangingTransition() -> Bool {
        (swipingToMode == .master && displayMode != .master) ||
        (swipingToMode == .overview && displayMode != .overview) ||
        displayMode == .masterOnboardAnim
    }

    func pctVal(from: CGFloat, to: CGFloat, pct: CGFloat) -> CGFloat {
        (to - from) * pct + from
    }
}

// MARK: - On-boarding animations

extension EdgeCardsController {

    func onboardAnimToMaster(_ handler: (()->Void)? = nil) {
        [masterContainer, topCardContainer].forEach {
            $0.transform = .init(translationX: view.bounds.width, y: 0)
            applyShadows($0, radius: Constant.cornerRadius, opacity: 1)
        }

        UIView.springAnimate(1, damping: 0.9, velocity: 0.5, animations: {
            self.topCardContainer.transform = .identity
            self.applyShadows(self.topCardContainer, radius: 0, opacity: 1)
            self.applyShadows(self.bottomCardContainer, radius: Constant.cornerRadius, opacity: 1)
            self.bottomCardContainer.transform = .init(scaleX: 0.975, y: 0.975)
                .concatenating(.init(translationX: -50, y: 0))
        })

        UIView.springAnimate(1, delay: 0.05, damping: 0.9, velocity: 0.5,
            animations: {
                self.masterContainer.transform = .identity
                self.applyShadows(self.masterContainer, radius: 0, opacity: 1)
            },
            completion: { _ in
                self.setDisplayMode(.master, animated: false)
                handler?()
            }
        )
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

        tapRecognizers = [tapMasterCard, tapTopCard, tapBottomCard]
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

        panRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(panned(_:))
        )
        panRecognizer.isEnabled = false
        view.addGestureRecognizer(panRecognizer)
    }

    func setupRecognizers(for mode: DisplayMode) {
        switch mode {
        case .overview:
            tapRecognizers.enumerated().forEach { $0.1.isEnabled = true }
        case .master:
            tapRecognizers.enumerated().forEach { $0.1.isEnabled = $0.0 != 0 }
        case .overviewTopCard, .topCard:
            tapRecognizers.enumerated().forEach { $0.1.isEnabled = $0.0 != 1 }
        case .overviewBottomCard, .bottomCard:
            tapRecognizers.enumerated().forEach { $0.1.isEnabled = $0.0 != 2 }
        default:
            ()
        }
        panRecognizer.isEnabled = mode != .master
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
        case overviewTopCard
        case overviewBottomCard
        case masterOnboardAnim

        func isFullScreen() -> Bool {
            switch self {
            case .master, .topCard, .bottomCard: return true
            default: return false
            }
        }

        func isNonMasterFullScreen() -> Bool {
            switch self {
            case .topCard, .bottomCard: return true
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
        static let shortAnim: TimeInterval = 0.15
        static let longAnim: TimeInterval = 0.4
        static let cardScl: CGFloat = 0.975
        static let contScl: CGFloat = 0.95
        static let displayModeShortAnim: TimeInterval = 0.8
        static let displayModeLongAnim: TimeInterval = 0.8
    }

    enum CT {
        static let mstrMax: CGFloat = 0.945
        static let mstrOv: CGFloat = 0.85
        static let topMax: CGFloat = 0.89
        static let topMin: CGFloat = 0.025
        static let topOv: CGFloat = 0.5
    }
}
