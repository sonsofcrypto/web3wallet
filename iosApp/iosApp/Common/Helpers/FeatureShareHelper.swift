// Created by web3d4v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct FeatureShareHelper {
    
    func shareVote(
        on web3Feature: Web3Feature,
        presentingIn: UIViewController
    ) {
        
        var text = Localized(
            "feature.vote.text",
            arg: "#" + web3Feature.hashTag
        )
        
        text.append("\n\n\(web3Feature.imageUrl)")
        
        let textEncoded = text.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""
        
        guard let url = "https://www.twitter.com/intent/tweet?text=\(textEncoded)".url else { return }
        
        UIApplication.shared.open(url)
    }
}
