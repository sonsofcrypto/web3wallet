package com.sonsofcrypto.web3wallet.android

import com.sonsofcrypto.web3lib.contract.ERC20
import com.sonsofcrypto.web3lib.contract.Interface
import com.sonsofcrypto.web3lib.contract.UniswapInterfaceMulticall
import com.sonsofcrypto.web3lib.provider.ProviderPocket
import com.sonsofcrypto.web3lib.provider.call
import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.provider.model.TransactionRequest
import com.sonsofcrypto.web3lib.provider.model.toByteArrayData
import com.sonsofcrypto.web3lib.provider.model.toByteArrayQnt
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.Network
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlin.time.Duration.Companion.seconds

class MultiCallTests {

    fun runAll() {
        GlobalScope.launch {
            delay(1.seconds)
            testER20Balances()
        }
    }

    fun assertTrue(actual: Boolean, message: String? = null) {
        if (!actual) throw Exception("Failed $message")
    }

    fun testER20Balances() = runBlocking {
        val address = "0x9aA80dCeD760224d59BEFe358c7C66C45e3BEA1C"
        val multiCallAddress = "0xcA11bde05977b3631167028862bE2a173976CA11"
        val erc20s = listOf(
            "0xdac17f958d2ee523a2206206994597c13d831ec7",
            "0xf0f9d895aca5c8678f706fb8216fa22957685a13"
        )
        val iface = Interface.ERC20()
        val data = iface.encodeFunction(iface.function("balanceOf"), listOf(address))
        val ifaceMulticall = Interface.UniswapInterfaceMulticall()
        val multicallFunc = ifaceMulticall.function("aggregate3")
        val multucallData = ifaceMulticall.encodeFunction(
            multicallFunc,
            listOf(erc20s.map { listOf(it, true, data) })
        )
        val provider = ProviderPocket(Network.ethereum())
        val result = provider.call(
            TransactionRequest(
                to = Address.HexString(multiCallAddress),
                data = DataHexString(multucallData),
            )
        )
        println("[RESULT] $result")
        val decoded = ifaceMulticall.decodeFunctionResult(
            multicallFunc,
            result.toByteArrayData()
        )
        println("[DECODED] $decoded")
    }
}
