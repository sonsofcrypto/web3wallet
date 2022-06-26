// Created by web3d4v on 26/06/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct ThemeHomeA {
    
}

extension ThemeHomeA: ThemeHome {
    
    func navBarColour() -> ThemeHomeNavBar {
        
        .init(
            backgroundColour: .init(rgb: 0x1D1D1D).withAlpha(0.94),
            foregroundColour: colour(for: .orange),
            tintColour: colour(for: .orange)
        )
    }
    
    func tabBarColour() -> ThemeHomeTabBar {
        
        .init(
            backgroundColour: .init(rgb: 0x161616).withAlpha(0.84),
            tintColour: colour(for: .pink),
            itemNormalColour: colour(for: .blue),
            itemSelectedColour: colour(for: .pink)
        )
    }
    
    func gradient() -> ThemeHomeGradient {
        
        .init(
            topColour: .init(rgb: 0xE73795),
            bottomColour: .init(rgb: 0x181849)
        )
    }
    
    func font(for font: ThemeHomeFont) -> UIFont {
        
        switch font {
            
        case .navBarTitle:
            return UIFont(name: "NaokoAA-Regular", size: 18)!
            
        case .title:
            return UIFont.font(.gothicA1, style: .regular, size: .title1)
            
        case .sectionTitle:
            return UIFont.font(.gothicA1, style: .regular, size: .headline)
            
        case .button:
            return UIFont.font(.gothicA1, style: .regular, size: .caption2)
        }
    }
}
