package com.sonsofcrypto.web3lib.signer.contracts

import com.sonsofcrypto.web3lib.provider.model.DataHexString
import com.sonsofcrypto.web3lib.provider.model.toBigIntData
import com.sonsofcrypto.web3lib.types.Address
import com.sonsofcrypto.web3lib.utils.BigInt
import com.sonsofcrypto.web3lib.utils.extensions.hexStringToByteArray
import com.sonsofcrypto.web3lib.utils.keccak256

private val abiParamLen = 32

open class Contract(
    var address: Address.HexString
) {
    open class Event()

    fun abiEncode(address: Address.HexString): ByteArray {
        val addressBytes = address.hexString.hexStringToByteArray()
        var result = ByteArray(abiParamLen - addressBytes.size)
        return result + addressBytes
    }

    fun abiDecode(value: String): BigInt {
        var idx = 2
        while (value[idx] == '0' && idx<(value.length-2)) {  idx += 1 }
        var stripped = value.substring(idx)
        stripped = if (stripped.length % 2 == 0) stripped else "0" + stripped
        return stripped.toBigIntData()
    }
}

class ERC20(address: Address.HexString) : Contract(address) {

    /**
     * Returns the name of the token.
     * @return public view virtual override returns (string memory)
     */
    fun name(): DataHexString = DataHexString(
        keccak256("name()".encodeToByteArray()).copyOfRange(0, 4)
    )

    /**
     * Returns the symbol of the token, usually a shorter version of the name.
     * @return public view virtual override returns (string memory)
     */
    fun symbol(): DataHexString = DataHexString(
        keccak256("symbol()".encodeToByteArray()).copyOfRange(0, 4)
    )

    /**
     * Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * @return public view virtual override returns (uint8)
     */
    fun decimals(): DataHexString = DataHexString(
        keccak256("decimals()".encodeToByteArray()).copyOfRange(0, 4)
    )

    /**
     * function transfer(address to, uint256 amount)
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     * @return public virtual override returns (bool)
     */
    fun transfer(to: Address.HexString, amount: BigInt): DataHexString = DataHexString(
        keccak256("decimals(address,uint256)".encodeToByteArray()).copyOfRange(0, 4)
    )

    /**
     * @dev See {IERC20-balanceOf}.
     * @return public view virtual override returns (uint256)
     */
    fun balanceOf(account: Address.HexString): DataHexString = DataHexString(
        keccak256("balanceOf(address)".encodeToByteArray()).copyOfRange(0, 4) +
            abiEncode(account)
    )
}