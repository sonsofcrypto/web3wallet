package coreCrypto

import (
	"golang.org/x/crypto/sha3"
	"hash"
)

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
