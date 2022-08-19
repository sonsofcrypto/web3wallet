package com.sonsofcrypto.web3lib.utils.extensions

import kotlin.math.min

/** Returns sublist to index. If index is greater than list returns full list */
inline fun <E>List<out E>.subListTo(index: Int): List<E> {
    if (this.isEmpty())
        return this
    return this.subList(0, min(index, this.size - 1))
}