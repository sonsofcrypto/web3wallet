package com.sonsofcrypto.web3lib.services.uniswap.contracts

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.signer.LegacyContract
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.abiEncode
import com.sonsofcrypto.web3lib.utils.keccak256

class Quoter(address: Address.HexString): LegacyContract(address) {

    /**
     * /// @inheritdoc IQuoter
     * function quoteExactInputSingle(
     *     address tokenIn,
     *     address tokenOut,
     *     uint24 fee,
     *     uint256 amountIn,
     *     uint160 sqrtPriceLimitX96
     * ) public override returns (uint256 amountOut)
     */

    fun quoteExactInputSingle(
        tokenIn: Address.HexString,
        tokenOut: Address.HexString,
        fee: UInt,
        amountIn: BigInt,
        sqrtPriceLimitX96: UInt,
    ):DataHexString = DataHexString(
        keccak256("quoteExactInputSingle(address,address,uint24,uint256,uint160)"
            .encodeToByteArray()).copyOfRange(0, 4) +
        abiEncode(tokenIn) +
        abiEncode(tokenOut) +
        abiEncode(fee) +
        abiEncode(amountIn) +
        abiEncode(sqrtPriceLimitX96)
    )
}