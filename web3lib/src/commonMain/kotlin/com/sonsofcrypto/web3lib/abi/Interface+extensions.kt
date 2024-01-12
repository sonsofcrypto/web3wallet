package com.sonsofcrypto.web3lib.abi

import com.sonsofcrypto.web3lib.utils.FileManager
import com.sonsofcrypto.web3lib.utils.FileManager.Location.BUNDLE

@Throws(Throwable::class)
fun Interface.Companion.named(name: String): Interface = fromJson(
    FileManager().readSync("contracts/$name.json").decodeToString()
)

fun Interface.Companion.ERC20(): Interface {
    cache.get("IERC20")?.let { return it }
    val iStr = FileManager().readSync("contracts/IERC20.json", BUNDLE).decodeToString()
    val intf = fromJson(iStr)
    cache["IERC20"] = intf
    return intf
}

fun Interface.Companion.Multicall3(): Interface {
    cache.get("Multicall3")?.let { return it }
    val fm = FileManager()
    val iStr = fm.readSync("contracts/Multicall3.json", BUNDLE).decodeToString()
    val intf = fromJson(iStr)
    cache["Multicall3"] = intf
    return intf
}
