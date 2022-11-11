package com.sonsofcrypto.web3lib.abi.integrations

import com.sonsofcrypto.web3lib.abi.AbiEncode
import com.sonsofcrypto.web3lib.abi.CallStack
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.extensions.toHexString
import io.ktor.utils.io.core.*

class UniswapV3 {
    companion object {
        fun exactInputSingle(
            tokenIn: Address.HexString,
            tokenOut: Address.HexString,
            fee: BigInt,
            recipient: Address.HexString,
            amountIn: BigInt,
            amountOutMinimum: BigInt,
            sqrtPriceLimitX96: BigInt
        ): Array<ByteArray> {
            val signature = "exactInputSingle((address,address,uint24,address,uint256,uint256,uint160))"
            return AbiEncode.encodeSubCall(
                AbiEncode.encodeCallSignature(signature).toHexString()
                    + AbiEncode.encode(
                        arrayOf("address","address","uint24","address","uint256","uint256","uint160"),
                        arrayOf(
                            tokenIn,
                            tokenOut,
                            fee,
                            recipient,
                            amountIn,
                            amountOutMinimum,
                            sqrtPriceLimitX96
                        )
                    ).toHexString()
            )
        }
        fun multicall(
            deadline: BigInt,
            tokenIn: Address.HexString,
            tokenOut: Address.HexString,
            fee: BigInt,
            recipient: Address.HexString,
            amountIn: BigInt,
            amountOutMinimum: BigInt,
            sqrtPriceLimitX96: BigInt
        ) : ByteArray {
            val multicall = exactInputSingle(tokenIn, tokenOut, fee, recipient, amountIn, amountOutMinimum, sqrtPriceLimitX96)
            return AbiEncode.encode(arrayOf("uint", "bytes[]"), arrayOf(deadline, multicall))
        }
    }
}

/**
 * struct ExactInputSingleParams {
 *     address tokenIn;
 *     address tokenOut;
 *     uint24 fee;
 *     address recipient;
 *     uint256 amountIn;
 *     uint256 amountOutMinimum;
 *     uint160 sqrtPriceLimitX96;
 * }
 */
data class UniswapV3ExactInputSingleParams(
    val tokenIn: ByteArray, // address
    val tokenOut: ByteArray, // address
    val fee: BigInt, // uint24
    val recipient: ByteArray, // address
    val amountIn: BigInt, // uint256
    val amountOutMinimum: BigInt, // uint256
    val sqrtPriceLimitX96: BigInt // uint256
) {

}