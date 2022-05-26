package crypto

import (
	"crypto/rand"
)

//SecureRand cryptographically secure random bytes of size or error
func SecureRand(size int) ([]byte, error) {
	entropy := make([]byte, size/8)
	if _, err := rand.Read(entropy); err != nil {
		return nil, err
	}
	return entropy, nil
}

//SecureRand2 2 cryptographically secure random bytes of size or error
func SecureRand2(size int) []byte {
	entropy := make([]byte, size/8)
	if _, err := rand.Read(entropy); err != nil {
		return nil
	}
	return entropy
}
