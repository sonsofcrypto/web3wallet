//
//  UIImageView+Extensions.swift
//  web3wallet
//
//  Created by web3 on 24/05/2022.
//

import UIKit

extension UIImageView {
    
    func load(url: String, placeholder: UIImage? = nil) {
        
        guard let url = URL(string: url) else { return }
        load(url: url)
    }
    
    func load(url: URL, placeholder: UIImage? = nil) {
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = Theme.color.tintLight
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
        activityIndicator.addConstraints(
            [
                .layout(anchor: .centerXAnchor),
                .layout(anchor: .centerYAnchor)
            ]
        )
        
        image = placeholder
        
        let cache: CacheImage = ServiceDirectory.assembler.resolve()
        
        if let image = cache.findImage(for: url) {
            activityIndicator.removeFromSuperview()
            self.image = image
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            
            if let data = try? Data(contentsOf: url) {
                
                if let image = UIImage(data: data) {
                    
                    cache.cache(image: image, at: url)
                    
                    DispatchQueue.main.async {
                        
                        activityIndicator.removeFromSuperview()
                        self?.image = image
                    }
                }
            }
        }
    }
}


