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

    func setImage(url: URL?, placeholder: Placeholder) {
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

        ServiceDirectory.Cache.image.image(url: url) { [weak self] result in
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
                    self?.removeActivityIndicator()
                }
            }
        }
    }

    func cancelImageLoad() {
        ServiceDirectory.Cache.image.cancel(nil, urlHash: tag)
    }

    func addActivityIndicator() {
        // TODO: Add activity indicator
    }
    
    func removeActivityIndicator() {
        // TODO: Remove activity indicator if needed
    }
}

