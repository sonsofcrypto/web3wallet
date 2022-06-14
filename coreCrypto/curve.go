package coreCrypto

import (
	"crypto/elliptic"
	"github.com/ethereum/go-ethereum/crypto/secp256k1"
	"log"
)

// CurveSecp256k1 is `int`, not type due to `go bind` support (it does not support enums)
const (
	CurveSecp256k1 = iota
)

const compressedPubKeyLen = 33

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
