package com.sonsofcrypto.web3lib.services.node

import android.content.Context.MODE_PRIVATE
import com.sonsofcrypto.web3lib.keyValueStore.application
import coreCrypto.CoreCrypto.newGethNode

actual class NodeConfig(
    val coreConfig: coreCrypto.NodeConfig = coreCrypto.NodeConfig()
)

actual class NodeInfo(private val coreInfo: coreCrypto.NodeInfo) {
    override fun toString(): String = coreInfo.toString()
}

actual class PeerInfos(private val coreInfos: coreCrypto.PeerInfos) {
    override fun toString(): String = coreInfos.toString()
}

actual class Node {

    private val coreNode: coreCrypto.Node

    /** Defaults mainnet config and platform appropriate dataFolder if null  */
    @Throws(Throwable::class)
    actual constructor(config: NodeConfig?, dataFolder: String?) {
        val path = dataFolder ?: defaultPath()
        val cnf = config?.coreConfig ?: coreCrypto.NodeConfig()
        coreNode = newGethNode(path, cnf)
    }

    /** Starts node */
    @Throws(Throwable::class)
    actual fun start() = coreNode.start()

    /** Shutdowns node */
    @Throws(Throwable::class)
    actual fun close() = coreNode.close()

    /** Gathers and returns a collection of metadata known about the host. */
    actual fun getNodeInfo(): NodeInfo = NodeInfo(coreNode.nodeInfo)

    /** Returns an array of metadata objects describing connected peers. */
    actual fun getPeersInfo(): PeerInfos = PeerInfos(coreNode.peersInfo)

    private fun defaultPath(): String =
        application.getDir("geth", MODE_PRIVATE).path
}