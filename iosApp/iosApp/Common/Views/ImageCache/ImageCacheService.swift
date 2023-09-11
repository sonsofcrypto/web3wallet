//
// Created by web3dev on 13/09/2020.
//

import UIKit

protocol ImageCacheService {

    typealias Handler = (Result<UIImage, Error>)->()

    func image(url: URL, handler: @escaping Handler)
    func cancel(_ url: URL?, urlHash: Int?)
}

class DefaultImageCache: ImageCacheService {

    static let shared = DefaultImageCache()
    
    private var errorCache: [String: Error] = [:]

    private let downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "ImageCache Queue"
        queue.maxConcurrentOperationCount = 20
        return queue
    }()

    func image(url: URL, handler: @escaping ImageCacheService.Handler) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let image = self?.cachedImage(for: url) {
                handler(.success(image))
                return
            }
            if let err = self?.cachedError(url: url) {
                handler(.failure(err))
                return
            }

            self?.downloadImage(at: url) { result in
                switch result {
                case let .success(image):
                    handler(.success(image))
                    self?.cache(image, url: url)
                case let .failure(err):
                    if case ImageCacheError.failedToCreateImageFromData = err {
                        self?.cache(err, url: url)
                    }
                    handler(.failure(err))
                }
            }
        }
    }

    func cancel(_ url: URL? = nil, urlHash: Int? = nil) {
        guard let id = url?.absoluteString.sdbmhash ?? urlHash else {
            return
        }

        downloadQueue.operations
            .first(where: { ($0 as? ImageDownloadOperation)?.urlHash == id })?
            .cancel()
    }

    private func downloadImage(
        at url: URL,
        handler: @escaping ImageCacheService.Handler
    ) {
        let urlHash = url.absoluteString.sdbmhash
        for op in downloadQueue.operations {
            if let op = op as? ImageDownloadOperation, op.urlHash == urlHash {
                op.additionalHandlers.append(handler)
                return
            }
        }
        let op = ImageDownloadOperation(url)
        op.completionBlock = { [weak op] in
            guard (op?.isCancelled ?? false) == false else {
                return
            }
            op?.additionalHandlers.append(handler)
            guard let result = op?.result else {
                op?.additionalHandlers.forEach {
                    $0(.failure(ImageCacheError.unknownOperationError))
                }
                return
            }
            op?.additionalHandlers.forEach { $0(result) }
        }
        downloadQueue.addOperation(op)
    }

    private func cachedImage(for url: URL) -> UIImage? {
        guard let data = try? Data(contentsOf: cacheURL(url)) else {
            return nil
        }
        return UIImage(data: data, scale: UIScreen.main.scale)
    }

    private func cache(_ image: UIImage, url: URL) {
        try? image.pngData()?.write(to: cacheURL(url))
    }
    
    private func cachedError(url: URL) -> Error? {
        return errorCache[url.absoluteString]
    }
    
    private func cache(_ error: Error, url: URL) {
        errorCache[url.absoluteString] = error
    }
    
    private func cachePath(_ url: URL) -> String {
        return NSTemporaryDirectory() + "\(url.absoluteString.sdbmhash).png"
    }

    private func cacheURL(_ url: URL) -> URL {
        return URL(fileURLWithPath: cachePath(url))
    }
}

// MARK: - ImageDownloadOperation

private final class ImageDownloadOperation: Operation {

    let urlHash: Int
    let url: URL

    var result: Result<UIImage, Error>? = nil
    var additionalHandlers: [(Result<UIImage, Error>)->()] = []

    init(_ url: URL) {
        self.url = url
        self.urlHash = url.absoluteString.sdbmhash
    }

    override func main() {
        if isCancelled {
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let scale = UIScreen.main.scale

            if isCancelled {
                return
            }

            guard let image = UIImage(data: data, scale: scale) else {
                result = .failure(ImageCacheError.failedToCreateImageFromData)
                return
            }

            result = .success(image)
        } catch {
            result = .failure(error)
        }
    }
}

// MARK: - Error

enum ImageCacheError: Error {
    case failedToLoadData
    case failedToCreateImageFromData
    case unknownOperationError
}
