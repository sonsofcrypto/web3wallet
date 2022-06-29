package coreCrypto

import (
	"fmt"
	"math/big"
)

type BigInt struct {
	store *big.Int
}

func NewBigInt(bytes []byte) *BigInt {
	var store big.Int
	store.SetBytes(bytes)
	return &BigInt{&store}
}

func NewBitInt(str string, base int) (*BigInt, error) {
	var store big.Int
	_, success := store.SetString(str, base)

	if !success {
		return nil, fmt.Errorf("Failed to part `BigInt` from `string`")
	}

	return &BigInt{&store}, nil
}

func (bi *BigInt) Bytes() []byte {
	return bi.store.Bytes()
}

func (bi *BigInt) Add(a *BigInt) {
	bi.store.Add(bi.store, a.store)
}
