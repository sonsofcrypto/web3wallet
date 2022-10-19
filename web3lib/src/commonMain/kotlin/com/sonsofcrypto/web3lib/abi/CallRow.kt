package com.sonsofcrypto.web3lib.abi

class CallRow {
    var type: String = ""
    var value: ByteArray = ByteArray(0)

    constructor(input: String) {
        type = input
    }
}