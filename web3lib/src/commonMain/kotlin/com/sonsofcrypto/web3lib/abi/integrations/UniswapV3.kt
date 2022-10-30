package com.sonsofcrypto.web3lib.abi.integrations

import com.sonsofcrypto.web3lib.abi.AbiEncode
import com.sonsofcrypto.web3lib.abi.CallStack
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
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
        ): String {
            val signature = "exactInputSingle((address,address,uint24,address,uint256,uint256,uint160))"
            val tuple = AbiEncode.encode(
                arrayOf(
                    AbiEncode.encode(tokenIn),
                    AbiEncode.encode(tokenOut),
                    AbiEncode.encode(fee),
                    AbiEncode.encode(recipient),
                    AbiEncode.encode(amountIn),
                    AbiEncode.encode(amountOutMinimum),
                    AbiEncode.encode(sqrtPriceLimitX96)
                )
            )
            println("TUPLE: " + tuple.toHexString())

            return CallStack(signature)
                .addVariable(0, tuple)
                .toAbiEncodedString()
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
            val eis = exactInputSingle(tokenIn, tokenOut, fee, recipient, amountIn, amountOutMinimum, sqrtPriceLimitX96)
            //println("EIS: " + eis)
            val call = CallStack("multicall(uint256,bytes[])")
                .addVariable(0, deadline)
                .addVariable(1, eis)
            println(call.toAbiEncodedString())
            return call.toAbiEncodedString().toByteArray()
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