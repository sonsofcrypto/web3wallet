package coreCrypto

import (
	"crypto/hmac"
	"crypto/sha256"
	"crypto/sha512"
	"golang.org/x/crypto/ripemd160"
	"golang.org/x/crypto/sha3"
	"hash"
	"log"
)

// HashFn is `int`, not type due to `go bind` support (it does not support enums)
const (
	HashFnSha256    = iota
	HashFnSha512    = iota
	HashFnKeccak256 = iota
	HashFnKeccak512 = iota
	HashFnRipemd160 = iota
)

// Hash pass one of the hash constants from top of the file. (`HashFnSha256`,
// `HashFnSha512`, ...) Enum not used due to `go bind` (does not support enums)
func Hash(data []byte, hashFn int) []byte {
	switch hashFn {
	case HashFnKeccak256:
		return Keccak256(data)
	case HashFnKeccak512:
		return Keccak512(data)
	default:
		h := HashFunc(hashFn)()
		h.Write(data)
		return h.Sum(nil)
	}
}

// HashFunc hash functions, use constants above
func HashFunc(h int) func() hash.Hash {
	switch h {
	case HashFnSha256:
		return sha256.New
	case HashFnSha512:
		return sha512.New
	case HashFnRipemd160:
		return ripemd160.New
	default:
		log.Fatalln("Hashing func of ", h, "type is not supported")
		return nil
	}
}

// HmacSha512 return hmacSha512 of data, using key
func HmacSha512(key []byte, data []byte) []byte {
	mac := hmac.New(sha512.New, key)
	mac.Write(data)
	return mac.Sum(nil)
}

const hashLength = 32

// KeccakState wraps sha3.state. In addition to the usual hash methods, it also supports
// Read to get a variable amount of data from the hash state. Read is faster than Sum
// because it doesn't copy the internal state, but also modifies the internal state.
type KeccakState interface {
	hash.Hash
	Read([]byte) (int, error)
}

// NewKeccakState creates a new KeccakState
func NewKeccakState() KeccakState {
	return sha3.NewLegacyKeccak256().(KeccakState)
}

// HashData hashes the provided data using the KeccakState and returns a 32 byte hash
func HashData(kh KeccakState, data []byte) []byte {
	h := make([]byte, hashLength)
	kh.Reset()
	kh.Write(data)
	kh.Read(h[:])
	return h
}

// Keccak256 calculates and returns the Keccak256 hash of the input data.
func Keccak256(data []byte) []byte {
	b := make([]byte, hashLength)
	d := NewKeccakState()
	d.Write(data)
	d.Read(b)
	return b
}

// Keccak512 calculates and returns the Keccak512 hash of the input data.
func Keccak512(data []byte) []byte {
	d := sha3.NewLegacyKeccak512()
	d.Write(data)
	return d.Sum(nil)
}
