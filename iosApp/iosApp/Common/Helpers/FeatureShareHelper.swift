// Created by web3d4v on 08/08/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

struct FeatureShareHelper {
    
    func shareVote(on proposal: ImprovementProposal) {
        let textEncoded = proposal.tweet.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""

        let urlEncoded = proposal.pageUrl.addingPercentEncoding(
            withAllowedCharacters: .urlHostAllowed
        ) ?? ""
        guard let url = "https://www.twitter.com/intent/tweet?text=\(textEncoded)&url=\(urlEncoded)".url else { return }
        UIApplication.shared.open(url)
    }
}
