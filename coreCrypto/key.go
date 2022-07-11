package coreCrypto

import (
	"bytes"
	"crypto/elliptic"
	"github.com/ethereum/go-ethereum/crypto/secp256k1"
	"golang.org/x/crypto/pbkdf2"
	"golang.org/x/crypto/scrypt"
	"log"
	"math/big"
)

// CurveSecp256k1 is `int`, not type due to `go bind` support (it does not support enums)
const (
	CurveSecp256k1 = iota
)

const compressedPubKeyLen = 33

// CompressedPubKey for given curve, user CurveXYZ constants above. (Not type due to `go bind` interop)
func CompressedPubKey(curve int, priv []byte) []byte {
	c := curveFor(curve)
	x, y := c.ScalarBaseMult(priv)
	var prefix byte = 0x2
	if isOdd(y) { // isOdd
		prefix |= 0x1
	}

	pub := make([]byte, 0, compressedPubKeyLen)
	pub = append(pub, prefix)

	return paddedAppend(compressedPubKeyLen-1, pub, x.Bytes())
}

// AddPrivKeys Add key to key on a curve
func AddPrivKeys(curve int, key1 []byte, key2 []byte) []byte {
	c := curveFor(curve)
	var key1Int big.Int
	var key2Int big.Int
	key1Int.SetBytes(key1)
	key2Int.SetBytes(key2)

	key1Int.Add(&key1Int, &key2Int)
	key1Int.Mod(&key1Int, c.Params().N)

	b := key1Int.Bytes()
	if len(b) < 32 {
		extra := make([]byte, 32-len(b))
		b = append(extra, b...)
	}
	return b
}

// AddPubKeys Add key to key on a curve
func AddPubKeys(curve int, key1 []byte, key2 []byte) []byte {
	c := curveFor(curve)
	x1, y1 := expandPublicKey(c, key1)
	x2, y2 := expandPublicKey(c, key2)
	return compressPublicKey(c.Add(x1, y1, x2, y2))
}

// IsBip44ValidPrv checks that key bip44 compliant
func IsBip44ValidPrv(curve int, key []byte) bool {
	c := curveFor(curve)
	if len(key) != 32 ||
		bytes.Compare(key, c.Params().N.Bytes()) >= 0 {
		return false
	}

	for _, val := range key {
		if val != 0 {
			return true
		}
	}

	return false
}

// IsBip44Compliant checks that key bip44 compliant
func IsBip44ValidPub(curve int, key []byte) bool {
	c := curveFor(curve)
	x, y := expandPublicKey(c, key)
	return !(x.Sign() == 0 || y.Sign() == 0)
}

// Hash pass one of the hash constants from top of the file. (`HashFnSha256`,
// `HashFnSha512`, ...) Enum not used due to `go bind` (does not support enums)
func curveFor(c int) elliptic.Curve {
	switch c {
	case CurveSecp256k1:
		return secp256k1.S256()
	default:
		log.Fatalln("Unsupported curve")
		return nil
	}
}

// As described at https://crypto.stackexchange.com/a/8916
func expandPublicKey(c elliptic.Curve, key []byte) (*big.Int, *big.Int) {
	Y := big.NewInt(0)
	X := big.NewInt(0)
	X.SetBytes(key[1:])

	// y^2 = x^3 + ax^2 + b
	// a = 0
	// => y^2 = x^3 + b
	ySquared := big.NewInt(0)
	ySquared.Exp(X, big.NewInt(3), nil)
	ySquared.Add(ySquared, c.Params().B)

	Y.ModSqrt(ySquared, c.Params().P)

	Ymod2 := big.NewInt(0)
	Ymod2.Mod(Y, big.NewInt(2))

	signY := uint64(key[0]) - 2
	if signY != Ymod2.Uint64() {
		Y.Sub(c.Params().P, Y)
	}

	return X, Y
}

func compressPublicKey(x *big.Int, y *big.Int) []byte {
	var key bytes.Buffer

	// Write header; 0x2 for even y value; 0x3 for odd
	key.WriteByte(byte(0x2) + byte(y.Bit(0)))

	// Write X coord; Pad the key so x is aligned with the LSB. Pad size is key
	// length - header size (1) - xBytes size
	xBytes := x.Bytes()
	for i := 0; i < (compressedPubKeyLen - 1 - len(xBytes)); i++ {
		key.WriteByte(0x0)
	}
	key.Write(xBytes)

	return key.Bytes()
}

// Secret storage constants
const (
	SecretStorageHeaderKDF        = "scrypt"
	SecretStorageCipherAes128Crt  = "aes-128-ctr"
	SecretStorageScryptN          = 1 << 18
	SecretStorageScryptP          = 1
	SecretStorageScryptR          = 8
	SecretStorageScryptDKLen      = 32
	SecretStoragePrivateKeyMinLen = 32
)

// ScryptKey derivation
func ScryptKey(pswd, salt []byte, N, r, p, keyLen int) []byte {
	dk, err := scrypt.Key(pswd, salt, N, r, p, keyLen)
	if err != nil {
		log.Panicln("Failed to derive key from password", err)
	}
	return dk
}

// Pbkdf2 pass one of the hash constants from top of the file. (`HashFnSha256`,
// `HashFnSha512`, ...) Enum not used due to `go bind` (does not support enums)
func Pbkdf2(password, salt []byte, iter, keyLen, hashFn int) []byte {
	return pbkdf2.Key(password, salt, iter, keyLen, HashFunc(hashFn))
}
