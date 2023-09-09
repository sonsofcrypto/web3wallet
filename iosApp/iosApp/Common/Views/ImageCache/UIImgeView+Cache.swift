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
        placeholder: Placeholder = .activityIndicator
    ) {
        setImage(
            url: url != nil ? URL(string: url!) : nil,
            fallBackUrl: fallBackUrl != nil ? URL(string: fallBackUrl!) : nil,
            placeholder: placeholder
        )
    }

    func setImage(
        url: URL?,
        fallBackUrl: URL? = nil,
        placeholder: Placeholder = .activityIndicator
    ) {
        let previousTag = tag
        let ogTag = url?.absoluteString.sdbmhash ?? 0

        switch placeholder {
        case let .image(image):
            if previousTag != ogTag {
                self.image = image
                removeActivityIndicator()
            }
        case .activityIndicator:
            if previousTag != ogTag {
                image = nil
                addActivityIndicator()
            }
        case .none:
            if previousTag != ogTag {
                image = nil
                addActivityIndicator()
            }
        }

        guard let url = url else {
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
                case let .failure(err):
                    print(err)
                    guard self?.tag == ogTag, let fallBack = fallBackUrl else {
                        self?.removeActivityIndicator()
                        return
                    }
                    self?.setImage(url: fallBack, placeholder: placeholder)
                }
            }
        }
    }

    func cancelImageLoad() {
        DefaultImageCache.shared.cancel(nil, urlHash: tag)
    }

    func addActivityIndicator() {
        // TODO: Add activity indicator
    }
    
    func removeActivityIndicator() {
        // TODO: Remove activity indicator if needed
    }
}

