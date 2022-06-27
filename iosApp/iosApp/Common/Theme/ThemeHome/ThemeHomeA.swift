// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct ThemeHomeA {
    
}

extension ThemeHomeA: ThemeHome {
    
    func navBarColour() -> ThemeHomeNavBar {
        
        .init(
            backgroundColour: .init(rgb: 0x1D1D1D).withAlpha(0.94),
            foregroundColour: .init(named: "orange")!,
            tintColour: .init(named: "orange")!
        )
    }
    
    func tabBarColour() -> ThemeHomeTabBar {
        
        .init(
            backgroundColour: .init(rgb: 0x161616).withAlpha(0.84),
            tintColour: .init(named: "pink")!,
            itemNormalColour: .init(named: "blue")!,
            itemSelectedColour: .init(named: "pink")!
        )
    }
    
    func gradient() -> ThemeHomeGradient {
        
        .init(
            topColour: .init(rgb: 0xE73795),
            bottomColour: .init(rgb: 0x351E54)
            //bottomColour: .init(rgb: 0x181849)
        )
    }
    
    func font(for font: ThemeFont) -> UIFont {
        
        switch font {
            
        case .largeTitle:
            return UIFont(name: "NaokoAA-Medium", size: 40)!
            
        case .navTitle:
            return UIFont(name: "NaokoAA-Regular", size: 18)!

        case .title1:
            return UIFont(name: "NaokoAA-Medium", size: 30)!

        case .title2:
            return UIFont(name: "NaokoAA-BlackItalic", size: 16)!

        case .title3:
            return UIFont(name: "NaokoAA-Medium", size: 40)!

        case .headline:
            return UIFont(name: "NaokoAA-Black", size: 16)!
            
        case .subheadline:
            return UIFont(name: "NaokoAA-Bold", size: 14)!

        case .body:
            return UIFont(name: "NaokoAA-Bold", size: 14)!
            
        case .callout:
            return UIFont(name: "NaokoAA-Bold", size: 16)!
            
        case .caption1:
            return UIFont(name: "NaokoAA-Bold", size: 14)!
            
        case .caption2:
            return UIFont(name: "NaokoAA-Bold", size: 14)!
            
        case .footnote:
            return UIFont(name: "NaokoAA-Bold", size: 14)!
        }
    }
    
    func colour(for colour: ThemeColour) -> UIColor {
        
        switch colour {
        case .text:
            return .init(named: "theme-a-text")!
            
        case .orange:
            return .init(named: "orange")!
        }
    }
}
