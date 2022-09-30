package com.sonsofcrypto.web3lib.utils.abi

import com.sonsofcrypto.web3lib.utils.BigInt

class CallRow {
    var type: String = ""
    var value: ByteArray = ByteArray(0)

    constructor(input: String) {
        type = input
    }
}