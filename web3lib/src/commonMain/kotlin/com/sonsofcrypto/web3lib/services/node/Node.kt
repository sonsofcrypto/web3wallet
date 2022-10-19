package com.sonsofcrypto.web3lib.services.node

expect class NodeConfig { }

expect class NodeInfo { }

expect class PeerInfos { }

expect class Node {
    /** Defaults mainnet config and platform appropriate dataFolder if null  */
    @Throws(Throwable::class)
    constructor(config: NodeConfig? = null, dataFolder: String? = null)
    /** Starts node */
    @Throws(Throwable::class)
    fun start()
    /** Shutdowns node */
    @Throws(Throwable::class)
    fun close()
    /** Gathers and returns a collection of metadata known about the host. */
    fun getNodeInfo(): NodeInfo
    /** Returns an array of metadata objects describing connected peers. */
    fun getPeersInfo(): PeerInfos
}
