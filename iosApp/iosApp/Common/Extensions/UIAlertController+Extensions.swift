// Created by web3d3v on 05/10/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit
import web3walletcore

extension UIAlertController {

    convenience init(
        _ viewModel: ErrorViewModel,
        handlers: [((UIAlertAction) -> Void)?]
    ) {
        self.init(
            title: viewModel.title,
            message: viewModel.body,
            preferredStyle: .alert
        )
        for (idx, val) in viewModel.actions.enumerated() {
            let handler = handlers[safe: idx]
            addAction(
                .init(title: val, style: .default, handler: handler ?? nil)
            )
        }
    }
}


extension AlertController {

    convenience init(
        _ viewModel: AlertViewModel,
        handler: @escaping (_ idx: Int)->()
    ) {
        self.init(
            title: viewModel.title,
            message: viewModel.body,
            preferredStyle: .alert
        )
        for (idx, action) in viewModel.actions.enumerated() {
            addAction(
                .init(title:
                    action.title,
                    style: action.actionStyle(),
                    handler: { _ in handler(idx) }
                )
            )
        }
        self.setImageMedia(viewModel.imageMedia, insets: .with(all: -10))
    }
}

extension AlertViewModel.Action {
    func actionStyle() -> UIAlertAction.Style {
        switch self.kind {
        case .cancel: return .cancel
        case .destructive: return .destructive
        default: return .default
        }
    }
}

/// Adds ability to display `UIImage` above the title label of `UIAlertController`.
/// Functionality is achieved by adding “\n” characters to `title`, to make space
/// for `UIImageView` to be added to `UIAlertController.view`. Set `title` as
/// normal but when retrieving value use `originalTitle` property.
class AlertController: UIAlertController {
    /// - Return: value that was set on `title`
    private(set) var originalTitle: String?
    private var spaceAdjustedTitle: String = ""
    private weak var imageView: UIImageView? = nil
    private var previousImgViewSize: CGSize = .zero
    private var imageInsets: UIEdgeInsets = .zero

    override var title: String? {
        didSet {
            // Keep track of original title
            if title != spaceAdjustedTitle {
                originalTitle = title
            }
        }
    }

    /// - parameter image: `UIImage` to be displayed about title label
    func setTitleImage(_ image: UIImage?, insets: UIEdgeInsets) {
        let imageView = addImageViewIfNeeded()
        imageView.image = image
        imageView.bounds.size = CGRect(zeroOrigin: image?.size ?? .zero)
            .inset(by: insets).size
    }

    func setImageMedia(_ media: ImageMedia?, insets: UIEdgeInsets) {
        guard let media = media else { return }
        let imageView = addImageViewIfNeeded()
        imageView.setImageMedia(media)
        if let image = imageView.image {
            imageView.bounds.size = CGRect(zeroOrigin: image.size)
                .inset(by: insets).size
        }
    }

    private func addImageViewIfNeeded() -> UIImageView {
        guard let imageView = imageView else {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            view.addSubview(imageView)
            self.imageView = imageView
            return imageView
        }
        return imageView
    }

    // MARK: -  Layout code

    override func viewDidLayoutSubviews() {
        guard let imageView = imageView else {
            super.viewDidLayoutSubviews()
            return
        }
        // Adjust title if image size has changed
        if previousImgViewSize != imageView.bounds.inset(by: imageInsets).size {
            previousImgViewSize = imageView.bounds.inset(by: imageInsets).size
            adjustTitle(for: imageView)
        }
        // Position `imageView`
        let linesCount = newLinesCount(for: imageView)
        let padding = Constants.padding(for: preferredStyle)
        imageView.center.x = view.bounds.width / 2.0
        imageView.center.y = padding + linesCount * lineHeight / 2.0
        super.viewDidLayoutSubviews()
    }

    /// Adds appropriate number of "\n" to `title` text to make space for `imageView`
    private func adjustTitle(for imageView: UIImageView) {
        let linesCount = Int(newLinesCount(for: imageView))
        let lines = (0..<linesCount).map({ _ in "\n" }).reduce("", +)
        spaceAdjustedTitle = lines + (originalTitle ?? "")
        title = spaceAdjustedTitle
    }

    /// - Return: Number new line chars needed to make enough space for `imageView`
    private func newLinesCount(for imageView: UIImageView) -> CGFloat {
        return ceil(imageView.bounds.inset(by: imageInsets).height / lineHeight)
    }

    /// Calculated based on system font line height
    private lazy var lineHeight: CGFloat = {
        return UIFont.preferredFont(
                forTextStyle: preferredStyle == .alert ? .headline : .callout
        ).pointSize
    }()

    struct Constants {
        static var padAlert: CGFloat = 22
        static var padSheet: CGFloat = 11
        static func padding(for style: UIAlertController.Style) -> CGFloat {
            return style == .alert ? Constants.padAlert : Constants.padSheet
        }
    }
}
