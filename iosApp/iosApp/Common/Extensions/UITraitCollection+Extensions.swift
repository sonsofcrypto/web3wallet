//
//  UITraitCollection+Extensions.swift
//  iosApp
//
//  Created by web3 on 21/07/2022.
//

import UIKit

extension UITraitCollection {
    
    var isDarkMode: Bool {
        
        userInterfaceStyle == .dark
    }
}
