// Created by web3d4v on 16/05/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct ServiceDirectory {
    
    static var assembler: Assembler!
    
    // TODO: Review
    static var transitionStyle: TransitionStyle = .cardFlip
    enum TransitionStyle {
        case cardFlip
        case sheet
    }
    
    // TODO: Review
    static var onboardingMode: OnboardingMode = .twoTap
    enum OnboardingMode {
        case oneTap
        case twoTap
    }
    
    static func rebootApp() {
        guard let window = UIApplication.shared.keyWindow else { return }
        UIBootstrapper(window: window).boot()
    }
}
