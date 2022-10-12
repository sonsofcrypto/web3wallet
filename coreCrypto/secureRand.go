package coreCrypto

import (
	"crypto/rand"
	"log"
)

// SecureRand cryptographically secure random bytes of size or error
func SecureRand(size int) ([]byte, error) {
	entropy := make([]byte, size)
	if _, err := rand.Read(entropy); err != nil {
		return nil, err
	}
	return entropy, nil
}

// SecureRandFatal cryptographically secure random bytes of size crashes if err
func SecureRandFatal(size int) []byte {
	entropy := make([]byte, size)
	if _, err := rand.Read(entropy); err != nil {
		log.Fatalln("Failed to generate entropy")
	}
	return entropy
}
