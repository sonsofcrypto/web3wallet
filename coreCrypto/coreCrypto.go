package coreCrypto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"crypto/sha256"
	"crypto/sha512"
	"errors"
	"golang.org/x/crypto/pbkdf2"
	"hash"
	"log"
)

// HashFn is `int` not type due to `go bind` support (it does not support enums)
const (
	HashFnSha256 = iota
	HashFnSha512 = iota
)

// HashFunc hash functions, use constants above
func HashFunc(h int) func() hash.Hash {
	switch h {
	case HashFnSha256:
		return sha256.New
	case HashFnSha512:
		return sha512.New
	}
	log.Fatalln("Hashing func of ", h, "type is not supported")
	return nil
}

// Hash pass one of the hash constants from top of the file. (`HashFnSha256`,
// `HashFnSha512`, ...) Enum not used due to `go bind` (does not support enums)
func Hash(data []byte, hashFn int) []byte {
	h := HashFunc(hashFn)()
	h.Write(data)
	return h.Sum(nil)
}

//SecureRand cryptographically secure random bytes of size or error
func SecureRand(size int) ([]byte, error) {
	entropy := make([]byte, size)
	if _, err := rand.Read(entropy); err != nil {
		return nil, err
	}
	return entropy, nil
}

// Pbkdf2 pass one of the hash constants from top of the file. (`HashFnSha256`,
// `HashFnSha512`, ...) Enum not used due to `go bind` (does not support enums)
func Pbkdf2(password, salt []byte, iter, keyLen, hashFn int) []byte {
	return pbkdf2.Key(password, salt, iter, keyLen, HashFunc(hashFn))
}

var (
	ErrDecrypt = errors.New("could not decrypt key with given password")
)

func AESCTRXOR(key, inText, iv []byte) ([]byte, error) {
	// AES-128 is selected due to size of encryptKey.
	aesBlock, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	stream := cipher.NewCTR(aesBlock, iv)
	outText := make([]byte, len(inText))
	stream.XORKeyStream(outText, inText)
	return outText, err
}

func AESCBCDecrypt(key, cipherText, iv []byte) ([]byte, error) {
	aesBlock, err := aes.NewCipher(key)
	if err != nil {
		return nil, err
	}
	decrypter := cipher.NewCBCDecrypter(aesBlock, iv)
	paddedPlaintext := make([]byte, len(cipherText))
	decrypter.CryptBlocks(paddedPlaintext, cipherText)
	plaintext := pkcs7Unpad(paddedPlaintext)
	if plaintext == nil {
		return nil, ErrDecrypt
	}
	return plaintext, err
}

// From https://leanpub.com/gocrypto/read#leanpub-auto-block-cipher-modes
func pkcs7Unpad(in []byte) []byte {
	if len(in) == 0 {
		return nil
	}

	padding := in[len(in)-1]
	if int(padding) > len(in) || padding > aes.BlockSize {
		return nil
	} else if padding == 0 {
		return nil
	}

	for i := len(in) - 1; i > len(in)-int(padding)-1; i-- {
		if in[i] != padding {
			return nil
		}
	}
	return in[:len(in)-int(padding)]
}
