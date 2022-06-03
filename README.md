# web3wallet

### NOTE: Currently under active development.

This repo contains iOS, Android and React browser extension apps. All apps use 
shared Kotlin `web3lib` for all of web3 needs. Creating and managing wallets, 
signing transactions, connecting to networks, interacting with smart contracts.

## Compilation instructions
- Clone and repo
```
git clone https://github.com/sonsofcrypto/web3wallet.git
```
- you will need to have `Go` environment setup and `gomobile` to compile 
`CoreCrypto`. More info in `coreCrypto/README.md`.
```
$ go install golang.org/x/mobile/cmd/gomobile@latest
$ go install golang.org/x/mobile/cmd/gobind@latest
$ gomobile init
```
- build `CoreCryto` dependency for `web3lib`. 
```
$ cd coreCrypto && chmod +x build.sh && ./build.sh
```
- build iOS run `./gradlew assembleXCFramework`, then open Xcode and run
- build Android simply run in AndroidStudio or use standards gradle tasks
- build Browser extension soon™

## TODO:
	- [x] bip39
	- [ ] bip44
	- [ ] Move keystore to kotlin (create, restore bip39, bip44, bip32)
    - [ ] RPC
    - [ ] Run light client
		- [ ] Pocket network
		- [ ] Infura
		- [ ] Alchyme    
    - [ ] Contract and sign transaction
    - [ ] Currencies metadata store
    - [ ] Swaps
	- [ ] Fix keychain storage bug

## Backlog:
    - [ ] Bip39 optimize performance of `WordList.indexOf`
	- [ ] Add support for 24 word mnemonics (option to select & text to scale down when entering)
	- [ ] Import private key
	- [ ] Handle multiple accounts from from same mnemonic
	- [ ] Connect harware wallet
	- [ ] Create multisig
	- [ ] Add bip39 validation 
	- [ ] Add inset for keybord and scroll to fiedl when keyboard comes up
 	- [ ] Implement custom layout for separators
 	- [ ] Fix add wallet dismiss animation when in cards mode
	- [ ] Interactive gesture for dismisg card flip
	- [ ] Validation UI for importing menmonic
	- [ ] Create password VC
	- [ ] Play haptics when swipe starts

For more info [sonsOfCrypto.com](https://sonsofcrypto.com/)
