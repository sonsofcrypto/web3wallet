//
//  UIImageView+Extensions.swift
//  web3wallet
//
//  Created by web3 on 24/05/2022.
//

import UIKit

extension UIImageView {
    
    func load(url: String) {
        
        guard let url = URL(string: url) else { return }
        load(url: url)
    }
    
    func load(url: URL) {
        
        let cache: CacheImage = ServiceDirectory.assembler.resolve()
        
        if let image = cache.findImage(for: url) {
            self.image = image
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            
            if let data = try? Data(contentsOf: url) {
                
                if let image = UIImage(data: data) {
                    
                    cache.cache(image: image, at: url)
                    
                    DispatchQueue.main.async {
                        
                        self?.image = image
                    }
                }
            }
        }
    }
}


