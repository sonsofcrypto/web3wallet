package com.sonsofcrypto.web3lib.services.uniswap.contracts

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.signer.contracts.Contract
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.types.AddressHexString
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.abiEncode
import com.sonsofcrypto.web3lib.utils.keccak256
import kotlinx.datetime.Instant

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
        val recipient: Recipient,
        val amountIn: BigInt,
        val amountOutMinimum: BigInt,
        val sqrtPriceLimitX96: BigInt
    ) {
        fun encoded(): ByteArray = abiEncode(Address.HexString(tokenIn)) +
            abiEncode(Address.HexString(tokenOut)) +
            abiEncode(fee) +
            recipient.abiEncoded() +
            abiEncode(amountOutMinimum) +
            abiEncode(sqrtPriceLimitX96)

        sealed class Recipient() {
            data class HexAddress(val address: AddressHexString): Recipient()
            object This: Recipient()
            object MsgSender: Recipient()

            fun abiEncoded(): ByteArray = when (this) {
                is HexAddress -> abiEncode(Address.HexString(this.address))
                is This -> abiEncode(BigInt.from(1))
                is MsgSender -> abiEncode(BigInt.from(2))
            }
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
            "exactInputSingle((address,address,uint24,address,uint256,uint256,uint160))"
                .encodeToByteArray()
        ).copyOfRange(0, 4)
        + params.encoded()
    )

    /**
     * @notice Unwraps the contract's WETH9 balance and sends it to msg.sender as ETH.
     * @dev The amountMinimum parameter prevents malicious contracts from stealing WETH9 from users.
     * @param amountMinimum The minimum amount of WETH9 to unwrap
     *
     * function unwrapWETH9(uint256 amountMinimum) external payable;
     */
    fun unwrapWETH9(amountMinimum: BigInt): DataHexString = DataHexString(
        abiEncode(amountMinimum)
    )

    /**
     * @notice Call multiple functions in the current contract and return the data from all of them if they all succeed
     * @dev The `msg.value` should not be trusted for any method callable from multicall.
     * @param deadline The time by which this function must be called before failing
     * @param data The encoded function data for each of the calls to make to this contract
     * @return results The results from each of the calls passed in via data
     *
     * function multicall(uint256 deadline, bytes[] calldata data) external payable returns (bytes[] memory results);
     */
    fun multicall(deadline: Instant, calldata: List<ByteArray>): DataHexString {
        var data = keccak256(
            "multicall(uint256,bytes[])".encodeToByteArray()
        ).copyOfRange(0, 4)

        data += abiEncode(BigInt.from(deadline.epochSeconds))

        /// MethodID: 0x5ae401dc
        /// 000000000000000000000000000000000000000000000000000000006311b9b8
        /// 0000000000000000000000000000000000000000000000000000000000000040 // Offset of array ?
        /// 0000000000000000000000000000000000000000000000000000000000000001 // Number of elements
        /// 0000000000000000000000000000000000000000000000000000000000000020 // Off Set of string (next line)
        /// 00000000000000000000000000000000000000000000000000000000000000e4 // String len pad right to 32 bytes
        /// 04e45aaf
        /// 0000000000000000000000001f9840a85d5af5bf1d1762f925bdaddc4201f984
        /// 0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f
        /// 0000000000000000000000000000000000000000000000000000000000000bb8
        /// 00000000000000000000000058aebec033a2d55e35e44e6d7b43725b069f6abc
        /// 00000000000000000000000000000000000000000000000025be36228d3f92a0
        /// 0000000000000000000000000000000000000000000000000000000000000000
        /// 0000000000000000000000000000000000000000000000000000000000000000
        /// 00000000000000000000000000000000000000000000000000000000

        /// 0000000000000000000000000000000000000000000000000000000000000020
        /// 0000000000000000000000000000000000000000000000000000000000000003
        /// 686d6d0000000000000000000000000000000000000000000000000000000000

        //0x5ae401dc
        /// 000000000000000000000000000000000000000000000000000000006311fea9
        /// 0000000000000000000000000000000000000000000000000000000000000040
        /// 0000000000000000000000000000000000000000000000000000000000000002
        /// 0000000000000000000000000000000000000000000000000000000000000040
        /// 0000000000000000000000000000000000000000000000000000000000000160
        /// 00000000000000000000000000000000000000000000000000000000000000e4
        /// 04e45aaf0000000000000000000000006b175474e89094c44da98b954eedeac4
        /// 95271d0f000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead908
        /// 3c756cc200000000000000000000000000000000000000000000000000000000
        /// 000001f400000000000000000000000000000000000000000000000000000000
        /// 0000000200000000000000000000000000000000000000000000000002be38a2
        /// b03e50670000000000000000000000000000000000000000000000000000597a
        /// 677660c800000000000000000000000000000000000000000000000000000000
        /// 0000000000000000000000000000000000000000000000000000000000000000
        /// 0000000000000000000000000000000000000000000000000000000000000044
        /// 49404b7c0000000000000000000000000000000000000000000000000000597a
        /// 677660c800000000000000000000000058aebec033a2d55e35e44e6d7b43725b
        /// 069f6abc00000000000000000000000000000000000000000000000000000000

        // Encode first param
        // Encode offset of array start 64 (guess from lenghts en)
        // Encode number of elements of array
        // Encode start of first string 64
        // (length of heads plust first lenght) Start of second start (for some reason length / 32 - 1)
        // Lenght of first string
        // First string
        // Lenght of second sctring
        // Second string

        // TODO: Refactor
        if (calldata.size == 1) {
            data += abiEncode(BigInt.from(64))
            data += abiEncode(BigInt.from(1))
            data += abiEncode(BigInt.from(32))
            data += abiEncode(BigInt.from(calldata[0].size))

            val remainder = calldata[0].size % 32
            if (remainder != 0) {
                var rightPadded = ByteArray(calldata[0].size + remainder)
                calldata[0].forEachIndexed { idx, byte -> rightPadded.set(idx, byte) }
                data += rightPadded
            } else data += calldata[0]

        } else if (calldata.size == 2) {
            data += abiEncode(BigInt.from(64))
            data += abiEncode(BigInt.from(2))
            data += abiEncode(BigInt.from(64))
            data += abiEncode(BigInt.from(calldata[0].size))


            var remainder = calldata[1].size % 32
            if (remainder != 0) {
                var rightPadded = ByteArray(calldata[0].size + remainder)
                calldata[0].forEachIndexed { idx, byte -> rightPadded.set(idx, byte) }
                data += rightPadded
            } else data += calldata[0]

            data += abiEncode(BigInt.from(calldata[1].size))

            remainder = calldata[1].size % 32
            if (remainder != 0) {
                var rightPadded = ByteArray(calldata[1].size + remainder)
                calldata[1].forEachIndexed { idx, byte -> rightPadded.set(idx, byte) }
                data += rightPadded
            } else data += calldata[1]

        } else {
            throw Exception("Unsupported number of calldatas ${calldata.size}, needs refactor")
        }
        return DataHexString(data)
    }
}