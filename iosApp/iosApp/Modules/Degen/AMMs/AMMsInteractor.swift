// Created by web3d3v on 11/02/2022.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

protocol AMMsInteractor: AnyObject {
    func dapps() -> [DApp]
}

// MARK: - DefaultAMMsInteractor

final class DefaultAMMsInteractor {

    private var degenService: DegenService

    init(_ degenService: DegenService) {
        self.degenService = degenService
    }
}

// MARK: - AMMsInteractor

extension DefaultAMMsInteractor: AMMsInteractor {

    func dapps() -> [DApp] {
        degenService.dapps(for: .amm)
    }
}
