package coreCrypto

import (
	"crypto/rand"
)

//SecureRand cryptographically secure random bytes of size or error
func SecureRand(size int) ([]byte, error) {
	entropy := make([]byte, size)
	if _, err := rand.Read(entropy); err != nil {
		return nil, err
	}
	return entropy, nil
}
