package web3lib

import (
	"fmt"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/sonsofcrypto/bip39"
	"log"
)

//HelloWorld export Hello world
func HelloWorld() {
	log.Println("Hello World")
}

// PrintMeAString export print me as string
func PrintMeAString(str string) {
	log.Println("Printing a string:", str)
}

func NewWrapperMnemonic(wordListPath string) string {
	// Load word list
	wordList, _ := bip39.LoadWordList(bip39.ListLangEn, wordListPath)
	// Generate bip39 compliant entropy
	entropy, _ := bip39.NewEntropy(bip39.EntropySize128)
	// Generate mnemonic from entropy
	mnemonic, _ := bip39.NewMnemonic(entropy, wordList)
	// Generate seed from mnemonic
	seed := bip39.NewSeed(mnemonic, "Secret Passphrase")

	fmt.Println("Hex:", hexutil.Encode(seed))

	return mnemonic
}

//func main() {
//	// Load word list
//	wordList, _ := bip39.LoadWordList(bip39.ListLangEn, "wordLists")
//	// Generate bip39 compliant entropy
//	entropy, _ := bip39.NewEntropy(bip39.EntropySize128)
//	// Generate mnemonic from entropy
//	mnemonic, _ := bip39.NewMnemonic(entropy, wordList)
//	// Generate seed from mnemonic
//	seed := bip39.NewSeed(mnemonic, "Secret Passphrase")
//
//	// Display mnemonic and keys
//	fmt.Println("Mnemonic:", mnemonic)
//	fmt.Println("Seed:", seed)
//	fmt.Println("Hex:", hexutil.Encode(seed))
//	fmt.Println("Int:", big.NewInt(0).SetBytes(seed[:]))
//}
