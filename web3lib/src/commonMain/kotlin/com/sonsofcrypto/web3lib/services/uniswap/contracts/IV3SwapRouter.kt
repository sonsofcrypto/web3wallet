package com.sonsofcrypto.web3lib.services.uniswap.contracts

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.signer.contracts.Contract
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.keccak256

class IV3SwapRouter(address: Address.HexString): Contract(address) {
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
    data class ExactInputSingleParams(
        val tokenIn: AddressHexString,
        val tokenOut: AddressHexString,
        val fee: UInt,
        val recipient: AddressHexString,
        val amountIn: BigInt,
        val amountOutMinimum: BigInt,
        val sqrtPriceLimitX96: BigInt
    ) {
        fun abiEncoded(): ByteArray {
            TODO("Implement")
            // 0x414bf389
            // 000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
            // 0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f
            // 00000000000000000000000000000000000000000000000000000000000001f4
            // 00000000000000000000000058aebec033a2d55e35e44e6d7b43725b069f6abc
            // 00000000000000000000000000000000000000000000000000000000630f8979
            // 00000000000000000000000000000000000000000000000000038d7ea4c68000
            // 0000000000000000000000000000000000000000000000000000000000000000
            // 0000000000000000000000000000000000000000000000000000000000000000
        }
    }

    /**
     * @notice Swaps `amountIn` of one token for as much as possible of another
     * token
     * @dev Setting `amountIn` to 0 will cause the contract to look up its own
     * balance,and swap the entire amount, enabling contracts to send tokens
     * before calling this function.
     * @param params The parameters necessary for the swap, encoded as
     * `ExactInputSingleParams` in calldata
     * @return amountOut The amount of the received token
     *
     * function exactInputSingle(
     *     ExactInputSingleParams calldata params
     * ) external payable returns (uint256 amountOut);
     */
    fun exactInputSingle(params: ExactInputSingleParams) = DataHexString(
        keccak256(
            "exactInputSingle((address,address,uint24,address,uint256,uint256,uint256,uint160))"
                .encodeToByteArray()
        ).copyOfRange(0, 4) + params.abiEncoded()
    )
}