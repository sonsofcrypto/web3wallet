package coreCrypto

import (
	"crypto/aes"
	"crypto/cipher"
	"errors"
	"log"
)

var (
	ErrDecrypt = errors.New("could not decrypt key with given password")
)

func AESCTRXOR(key, inText, iv []byte) ([]byte, error) {
	// AES-128 is selected due to size of encryptKey.
	aesBlock, err := aes.NewCipher(key)
	if err != nil {
		log.Println("=== Returning err 1:", err, "key len:", len(key))
		return nil, err
	}
	stream := cipher.NewCTR(aesBlock, iv)
	outText := make([]byte, len(inText))
	stream.XORKeyStream(outText, inText)
	return outText, err
}

func AESCTRXOREmptyOnError(key, inText, iv []byte) []byte {
	data, err := AESCTRXOR(key, inText, iv)
	if err != nil {
		return make([]byte, 0)
	}
	return data
}

func AESCBCDecrypt(key, cipherText, iv []byte) ([]byte, error) {
	aesBlock, err := aes.NewCipher(key)
	if err != nil {
		log.Println("=== Returning err 2:", err, "key len:", len(key))
		return nil, err
	}
	decrypter := cipher.NewCBCDecrypter(aesBlock, iv)
	paddedPlaintext := make([]byte, len(cipherText))
	decrypter.CryptBlocks(paddedPlaintext, cipherText)
	plaintext := pkcs7Unpad(paddedPlaintext)
	if plaintext == nil {
		log.Println("=== Returning err 2:", err, "key len:", len(key))
		return nil, ErrDecrypt
	}
	return plaintext, err
}

func AESCBCDecryptEmptyOnError(key, cipherText, iv []byte) []byte {
	data, err := AESCBCDecrypt(key, cipherText, iv)
	if err != nil {
		return make([]byte, 0)
	}
	return data
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
