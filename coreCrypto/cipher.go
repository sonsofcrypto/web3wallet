package coreCrypto

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/ecdsa"
	"crypto/elliptic"
	"errors"
	"fmt"
	"github.com/ethereum/go-ethereum/common/math"
	"github.com/ethereum/go-ethereum/crypto/secp256k1"
	"log"
	"math/big"
)

var (
	ErrDecrypt = errors.New("could not decrypt key with given password")
)

// DigestLength sets the signature digest exact length
const DigestLength = 32

func Sign(digestHash []byte, prv []byte, curve int) (sig []byte, err error) {
	key := priv(prv, curveFor(curve))
	return _sign(digestHash, key)
}

func SignEmptyOnError(digestHash []byte, prv []byte, curve int) []byte {
	sig, err := Sign(digestHash, prv, curve)
	if err != nil {
		log.Println(err)
		return make([]byte, 0)
	}
	return sig
}

func _sign(digestHash []byte, prv *ecdsa.PrivateKey) (sig []byte, err error) {
	if len(digestHash) != DigestLength {
		return nil, fmt.Errorf(
			"required hash is %d bytes (%d)",
			DigestLength, len(digestHash),
		)
	}
	seckey := math.PaddedBigBytes(prv.D, prv.Params().BitSize/8)
	defer zeroBytes(seckey)
	return secp256k1.Sign(digestHash, seckey)
}

func priv(keyBytes []byte, c elliptic.Curve) *ecdsa.PrivateKey {
	k := new(big.Int).SetBytes(keyBytes)
	priv := new(ecdsa.PrivateKey)
	priv.PublicKey.Curve = c
	priv.D = k
	priv.PublicKey.X, priv.PublicKey.Y = c.ScalarBaseMult(k.Bytes())
	return priv
}

func zeroBytes(bytes []byte) {
	for i := range bytes {
		bytes[i] = 0
	}
}

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
