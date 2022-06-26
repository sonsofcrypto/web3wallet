// Created by web3d3v on 12/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import UIKit

extension UIColor {

    static var bgGradientTop = UIColor(named: "bgGradientTop")!
    static var bgGradientTopSecondary = UIColor(named: "bgGradientTopSecondary")!
    static var bgGradientBottom =  UIColor(named: "bgGradientBottom")!
    static var tintPrimary = UIColor(named: "tintPrimary")!
    static var tintSecondary = UIColor(named: "tintSecondary")!
    static var textColor = UIColor(named: "textColor")!
    static var textColorSecondary = UIColor(named: "textColorSecondary")!
    static var textColorTertiary = UIColor(named: "textColorTertiary")!
    static var appRed = UIColor(named: "appRed")!
    static var appGreen = UIColor(named: "appGreen")!
}

extension UIColor {

    func withAlpha(_ alpha: CGFloat) -> UIColor {
        withAlphaComponent(alpha)
    }

}

extension UIColor {
    
   convenience init(red: Int, green: Int, blue: Int) {
       
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
