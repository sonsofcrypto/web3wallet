package com.sonsofcrypto.web3lib.provider

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.AddressHexString

@Throws(Throwable::class)
suspend fun Provider.call(to: AddressHexString, data: DataHexString): DataHexString {
    return call(TransactionRequest(to = Address.HexString(to), data = data))
}