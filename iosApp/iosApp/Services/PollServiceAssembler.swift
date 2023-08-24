//
//  PollServiceAssembler.swift
//  iosApp
//
//  Created by anon on 24/08/2023.
//

import Foundation
import Foundation
import web3walletcore

final class PollServiceAssembler: AssemblerComponent {

    func register(to registry: AssemblerRegistry) {

        registry.register(scope: .singleton) { resolver -> PollService in
            DefaultPollService(blockTimer: false)
        }
    }
}
