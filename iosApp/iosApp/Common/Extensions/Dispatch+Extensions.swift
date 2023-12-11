// Created by web3d3v on 10/12/2023.
// Copyright (c) 2022 Sons Of Crypto.
// SPDX-License-Identifier: MIT

import Foundation

func asyncMain(_ delay: TimeInterval = 0.0, block: @escaping ()-> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { block() }
}

