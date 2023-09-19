# web3wallet by sons of crypto Ξ

| Prod / AppStore                                         | Staging                                                  | Dev / Nightly                                                  |
|---------------------------------------------------------|----------------------------------------------------------|----------------------------------------------------------------|
| ![pro](bundledAssets/images/testflight_prod.png)        | ![staging](bundledAssets/images/testflight_staging.png)  | ![dev.png](bundledAssets/images/testflight_dev.png)            |
| web3wallet by sons of crypto Ξ v1.0 #28                 | web3wallet by sons of crypto S v1.0 #28                  | web3wallet by sons of crypto D v1.0 #28                        |
| AppStore RC.                                            | New features not quite AppStore ready. Great for testing | Living on the bleeding edge. Latest features, latest bugs. 🐛  |
| [Download](https://testflight.apple.com/join/I4DFVaiH)  | [Download](https://testflight.apple.com/join/5GiDXNJ3)   | [Download](https://testflight.apple.com/join/85JEPH96)         |

All three builds can be installed simultaneously. For more info about web3wallet
head over to [sonsofcrypto.com](https://sonsofcrypto.com/).


# Release Notes 

### v1.0 #28

Initial open beta MVP release of the most cypherpunk web3 wallet.
- web3 secret storage, bip39, bip44
- web3lib kotlin multiplatform web3 labrary loosely based on [ethersjs](https://github.com/ethers-io/ethers.js)
- ERC20s & NFTs support
- [Pokt.Network](https://www.pokt.network/), [Alchemy](https://www.alchemy.com/) support
- Vote on next features via WIPs in app
- Native [Uniswap](https://uniswap.org/) v3 swap integration. Interacts with smart contracts directly.
- Native [Cult DAO](https://cultdao.io/) governance integration.
- Four wild themes


Security note: All the cryptographic primitives / functions sercureRand, signing
etc are handled via very same code  
[Go Ethereum](https://github.com/ethereum/go-ethereum) uses. Binded to Kotlin 
Multiplatform via `coreCrypto` wrapper library using 
[gomobile](https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile).

## by degens for degens
<p align="center">
  <img src="bundledAssets/images/first_launch_teaser_7.gif"/>
  <br/><a href="https://sonsofcrypto.com">sonsofcrypto.com</a>
</p>