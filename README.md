# web3wallet

### NOTE: Currently under active development. MVP within 4 weeks.

This repo contains iOS, Android and React browser extension apps. All apps use shared GoLang `web3lib` for all of web3 needs. Creating and managing wallets, signing transactions, connecting to networks, interacting with smart contracts.

## Compilation instructions
- Clone and checkout submodules `web3lib`
```
git clone https://github.com/sonsofcrypto/web3wallet.git
git submodule update --init --recursive
```
- currently `web3lib` have to build manually instuctions [here](https://github.com/sonsofcrypto/web3lib). This will soon be automated. 


## TODO: MVP 1.0 4 weeks
	- [] w1 Key Store and associated UI (create, restore bip39, bip44, bip32)
	- [] Web3lib integration
	- [] bip39
	- [] bip44
	- [] KeyStore
		- [] Create
		- [] Import
		- [] Update settings
		- [] List
	- [] Import private key
	- [] Handle multiple accounts from from same mnemonic
	- [] Connect harware wallet
	- [] Create multisig

## UI tasks: 
	- [x] Layout for topCard
	- [x] Fix tapping on home screen
	- [x] Fix end of swipe gesture to left from home screen
	- [] Create wallet VC
	- [] Animate to home screen after creating wallet
	- [] Create wallet to transition
	- [] Create wallet from transition
	- [] Add setting to cell 
	- [] Add edit / settings mode
	- [] Add restore VC
	- [] Swiping on overview (Either go to bottom or master)
	- [] Swiping on top card (Either go to bottom or master)
	- [] Swiping on bottom card (Either go to network)
	- [] Aninate neon logo on apprearif empty
	- [] Create sheet view for buttons
	- [] Animate buttons on appear if wallets is empty
	- [] Create password VC
	- [] Play haptics when swipe starts

	- [] w2 Connection to networks
		- [] RPC APIs
		- [] Run light client
		- [] Pocket network
		- [] Infura
		- [] Alchyme
	- [] w3 Homescreen
	- [] w4 Send / Recieve

## TODO(web3dgn):
	- [] Under construction wireframe
	- [] Add theme option to settings
		- [] Theme picker module
	- [] Tab bar icons are not showing until first tap on the tab. Dont know why
	- [] Add swipe to delete to wallets scree
	- [] Add under construction with animation

## TODO(design4.crypto):
	- [] Redesign enter PIN / Pass / Salt

## MVP 2.0 4 weeks
	- [] Additional networks support
	- [] As many integrations as posible
	- [] Stuff left out from MVP 1.0

For more info [sonsOfCrypto.com](https://sonsofcrypto.com/)
