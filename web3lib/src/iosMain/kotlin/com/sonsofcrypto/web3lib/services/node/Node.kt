@file:OptIn(ExperimentalForeignApi::class)

package com.sonsofcrypto.web3lib.services.node

import CoreCrypto.CoreCryptoNewGethNodeFataln
import CoreCrypto.CoreCryptoNode
import CoreCrypto.CoreCryptoNodeConfig
import CoreCrypto.CoreCryptoNodeInfo
import CoreCrypto.CoreCryptoPeerInfos
import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSDocumentDirectory
import platform.Foundation.NSSearchPathForDirectoriesInDomains
import platform.Foundation.NSUserDomainMask

actual class NodeConfig(
    val coreConfig: CoreCryptoNodeConfig = CoreCryptoNodeConfig()
)

actual class NodeInfo(private val coreInfo: CoreCryptoNodeInfo) {
    override fun toString(): String = coreInfo.string()
}

actual class PeerInfos(private val coreInfos: CoreCryptoPeerInfos) {
    override fun toString(): String = coreInfos.string()
}

actual class Node {

    private val coreNode: CoreCryptoNode

    /** Defaults mainnet config and platform appropriate dataFolder if null  */
    @Throws(Throwable::class)
    actual constructor(config: NodeConfig?, dataFolder: String?) {
        val path = dataFolder ?: defaultPath()
        val cnf = config?.coreConfig ?: CoreCryptoNodeConfig()
        coreNode = CoreCryptoNewGethNodeFataln(path, cnf)
            ?: throw Error.InstantiateNode
    }

    /** Starts node */
    @Throws(Throwable::class)
    actual fun start() {
        coreNode.start(null)
    }

    /** Shutdowns node */
    @Throws(Throwable::class)
    actual fun close() {
        coreNode.close(null)
    }

    /** Gathers and returns a collection of metadata known about the host. */
    actual fun getNodeInfo(): NodeInfo = NodeInfo(
        coreNode.getNodeInfo() ?: throw Error.NodeInfo
    )

    /** Returns an array of metadata objects describing connected peers. */
    actual fun getPeersInfo(): PeerInfos = PeerInfos(
        coreNode.getPeersInfo() ?: throw Error.PeersInfo
    )

    private fun defaultPath(): String = (NSSearchPathForDirectoriesInDomains(
        NSDocumentDirectory,
        NSUserDomainMask,
        true
    ).first() as String)!!

    /** Exceptions */
    sealed class Error(
        message: String? = null,
        cause: Throwable? = null
    ) : Exception(message, cause) {
        constructor(cause: Throwable) : this(null, cause)
        /** Failed to instance geth node */
        object InstantiateNode: Error()
        /** Failed to get `NodeInfo` */
        object NodeInfo: Error()
        /** Failed to get `PeersInfo` */
        object PeersInfo: Error()
    }
}
