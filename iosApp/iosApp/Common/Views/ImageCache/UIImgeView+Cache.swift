//
// Created by web3dev on 11/09/2020.
//

import UIKit

extension UIImageView {

    enum Placeholder {
        case image(UIImage)
        case activityIndicator
        case none
    }

    func setImage(
        url: String?,
        fallBackUrl: String? = nil,
        fallBackText: String? = nil,
        placeholder: Placeholder = .activityIndicator
    ) {
        setImage(
            url: url != nil ? URL(string: url!) : nil,
            fallBackUrl: fallBackUrl != nil ? URL(string: fallBackUrl!) : nil,
            fallBackText: fallBackText,
            placeholder: placeholder
        )
    }

    func setImage(
        url: URL?,
        fallBackUrl: URL? = nil,
        fallBackText: String? = nil,
        placeholder: Placeholder = .activityIndicator
    ) {
        let previousTag = tag
        let ogTag = url?.absoluteString.sdbmhash ?? 0
                
        guard previousTag != ogTag else {
            return
        }
        
        cancelImageLoad()
        addFallbackLabel(fallBackText)
        
        switch placeholder {
        case let .image(image):
            self.image = image
            removeActivityIndicator()
            removeFallbackLabel()
        case .activityIndicator:
            image = nil
            addActivityIndicator()
        case .none:
            image = nil
            removeActivityIndicator()
        }

        guard let url = url else {
            removeFallbackLabel()
            removeActivityIndicator()
            addFallbackLabel(fallBackText)
            return
        }

        tag = ogTag

        DefaultImageCache.shared.image(url: url) { [weak self] result in
            DispatchQueue.main.async {
                guard self?.tag == ogTag else {
                    return
                }
                switch result {
                case let .success(image):
                    self?.image = image
                    self?.removeActivityIndicator()
                    self?.removeFallbackLabel()
                case let .failure(err):
                    guard self?.tag == ogTag,
                          url.absoluteString != fallBackUrl?.absoluteString,
                          let fallBack = fallBackUrl else {
                            self?.addFallbackLabel(fallBackText)
                            self?.removeActivityIndicator()
                            return
                    }
                    self?.setImage(
                        url: fallBack,
                        fallBackText: fallBackText,
                        placeholder: placeholder
                    )
                }
            }
        }
    }

    func cancelImageLoad() {
        DefaultImageCache.shared.cancel(nil, urlHash: tag)
        tag = 0
    }

    // MARK: - Activity Indicator

    func addActivityIndicator() {
        guard activityIndicatorView() == nil else {
            return
        }
        
        let indicator = UIActivityIndicatorView(style: .whiteLarge)
        indicator.tag = Constant.activityIndicatorTag
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.autoresizingMask = [
            .flexibleTopMargin,
            .flexibleBottomMargin,
            .flexibleRightMargin,
            .flexibleLeftMargin
        ]
        indicator.center = bounds.midXY
        addSubview(indicator)
        
        let contraints = [
            indicator.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),
            indicator.heightAnchor.constraint(greaterThanOrEqualToConstant: 24),
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]

        addConstraints(contraints)
        contraints.forEach { $0.isActive = true }
        indicator.startAnimating()
    }
    
    func removeActivityIndicator() {
        activityIndicatorView()?.removeFromSuperview()
    }

    private func activityIndicatorView() -> UIView? {
        subviews.filter {
            $0.tag == Constant.activityIndicatorTag &&
            $0 as? UIActivityIndicatorView != nil
        }.first as? UIActivityIndicatorView
    }

    // MARK: - Fallback Label

    func addFallbackLabel(_ text: String?) {
        guard fallbackLabel() == nil else {
            fallbackLabel()?.text = text
            return
        }
        guard let text = text else {
            return
        }
        let label = UILabel(with: .body)
        label.text = text
        label.textAlignment = .center
        label.numberOfLines = 0
        label.tag = Constant.fallbackLabelTag
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(label)
    }

    func removeFallbackLabel() {
        fallbackLabel()?.removeFromSuperview()
    }

    private func fallbackLabel() -> UILabel? {
        subviews.filter {
            $0.tag == Constant.fallbackLabelTag &&
            $0 as? UILabel != nil
        }.first as? UILabel
    }

    private enum Constant {
        static let activityIndicatorTag: Int = 69420
        static let fallbackLabelTag: Int = 42069
    }
}

// NOTE: Temporary debug code

//if debugUrlContains(targetDebugString) {
//    print("[UImageViews+Cache] \(address()) addActivityIndicator REMOVE")
//}

//var debugMap = [String: [String]]()
//let targetDebugString = "high.mp4"
//
//extension UIImageView {
//
//    func setDebugKeys(_ url: String?, _ fallback: String?) {
//        let address = "\(Unmanaged.passUnretained(self).toOpaque())"
//        var urls = [String]()
//        if let url = url {
//            urls.append(url)
//            print("[UImageViews+Cache] \(Unmanaged.passUnretained(self).toOpaque()) url1 \(url)")
//        }
//        if let fallback = fallback {
//            print("[UImageViews+Cache] \(Unmanaged.passUnretained(self).toOpaque()) fallback \(fallback)")
//            urls.append(fallback)
//        }
//        debugMap[address] = urls
//        if debugUrlContains(targetDebugString) {
//            print("[UImageViews+Cache] \(Unmanaged.passUnretained(self).toOpaque()) address \(address)")
//        }
//    }
//
//    func debugUrl() -> [String] {
//        return debugMap["\(Unmanaged.passUnretained(self).toOpaque())"] ?? []
//    }
//
//    func debugUrlContains(_ value: String) -> Bool {
//        for url in debugUrl() {
//            if url.contains(value) {
//                return true
//            }
//        }
//        return false
//    }
//}
