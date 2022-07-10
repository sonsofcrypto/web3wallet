package com.sonsofcrypto.web3lib_utils


class Trie {

    data class Node(
        var word: String? = null,
        val childNodes: MutableMap<Char, Node> = mutableMapOf()
    )

    private val root = Node()

    fun insert(word: String) {
        var currentNode = root
        for (char in word) {
            if (currentNode.childNodes[char] == null) {
                currentNode.childNodes[char] = Node()
            }
            currentNode = currentNode.childNodes[char]!!
        }
        currentNode.word = word
    }

    fun search(word: String): Boolean {
        var currentNode = root
        for (char in word) {
            if (currentNode.childNodes[char] == null) {
                return false
            }
            currentNode = currentNode.childNodes[char]!!
        }
        return currentNode.word != null
    }

    fun startsWith(word: String): Boolean {
        var currentNode = root
        for (char in word) {
            if (currentNode.childNodes[char] == null) {
                return false
            }
            currentNode = currentNode.childNodes[char]!!
        }
        return currentNode.word == null
    }
}
