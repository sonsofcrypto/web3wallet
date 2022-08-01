package com.sonsofcrypto.web3lib.utils

import kotlinx.serialization.Serializable

@Serializable
class Trie {

    @Serializable
    data class Node(
        var word: String? = null,
        val children: MutableMap<Char, Node> = mutableMapOf()
    )

    private val root = Node()

    fun insert(word: String) {
        var node = root
        for (char in word) {
            if (node.children[char] == null) {
                node.children[char] = Node()
            }
            node = node.children[char]!!
        }
        node.word = word
    }

    fun search(word: String): Boolean {
        var node = root
        for (char in word) {
            if (node.children[char] == null) {
                return false
            }
            node = node.children[char]!!
        }
        return node.word != null
    }

    fun startsWith(word: String): Boolean {
        var node = root
        for (char in word) {
            if (node.children[char] == null) {
                return false
            }
            node = node.children[char]!!
        }
        return node.word == null
    }

    fun wordsStartingWith(prefix: String): List<String> {
        var current = root

        prefix.forEach {
            val child = current.children[it] ?: return emptyList()
            current = child
        }

        return collections(prefix, current)
    }

    private fun collections(prefix: String, node: Node): List<String> {
        val results = mutableListOf<String>()

        // is terminating
        if (node.word != null) {
            results.add(prefix)
        }

        node.children?.forEach { (key, child) ->
            results.addAll(collections(prefix + key, child))
        }
        return results
    }
}