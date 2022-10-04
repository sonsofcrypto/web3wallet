package com.sonsofcrypto.web3lib.utils.abi.integrations

import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.abi.CallStack

class CultDao {
    companion object {
        fun withdraw (_pid: BigInt, _amount: BigInt) {
            val signature = "withdraw(uint256,uint256)"

        }
        fun deposit (_pid: BigInt, _amount: BigInt) : String {
            val signature = "deposit(uint256,uint256)"
            return CallStack(signature)
                .addVariable(0, BigInt.from("0")) // _pid (uint256)
                .addVariable(1, _amount) //_amount (uint256)
                .toAbiEncodedString()
        }
        fun claimCULT (_pid: BigInt) {
            val signature = "claimCULT(uint256)"
        }
        fun approve (spender: Address.HexString, amount: BigInt) {
            val signature = "approve(address,uint256)"

        }
    }
}