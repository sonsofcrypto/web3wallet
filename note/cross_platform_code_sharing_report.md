# Cross-platform code sharing issue report

## Background
Goal to build best iOS, Android and Browser extension wallets. We want to deliver most polished, 11 out of 10 experience. With a lot of custom UI and interactions, that is extremely snappy and performant. You don't really get that using something like [RectJS](https://reactjs.org/). But at the same time there is not reason to write all the crypto code and much of the business logic trice. We were writing all that code shared [Go](https://go.dev/) library.

## Why choose GO?
- Extremely stable and performant
- Its concurrency model is a delight
- Rich ecosystem and libraries
- [Geth](https://geth.ethereum.org/) itself if written in go. This would allow as to use the very same cryptographic libraries as Geth. If it's good enough for Geth, it's good enough for us.
- I had descent amount of experience working with Go.
- co-created by Ken Thompson, creator of Unix and B (predecessor of C) half a century ago. Now with life time of coding experience, co-created new language.

## What was the issue?
I briefly looked at [gomobile](https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile). It is a tool that creates binding for Obj-C / Swift (iOS) and Java / Kotlin (Android). Go itself supports compilation to [WASM](https://webassembly.org/), so that javascript covered as well. Binding allows you to interact with functions and types from library written in another language. There is myriad of sample of code, app examples and documentation. I wrote a few simple test functions, generated binding for Swift and tested them form Swift. Worked like a charm. Go is no-nonsense language and ecosystem. Everything is stable and just works. I have been writing shared crypto code in Go library. We were writing UI and mocking services written in shared library. I was going integrate it all and write native feeling [Swift](https://developer.apple.com/swift/) wrappers around Go modules. That was mid last week. And thats when I found out that `gomobile` is practically unusable for production. (╯°□°)╯︵ ┻━┻ 

## Why `gomobile` is unusable in prod?
There are severe limitation on what types they are able to export for binding. This makes it practically unusable for our purposes. We would have to basically pass everything as binary data. Giving up all the type safely and convenience both Swift and Go give you. For example it can't even handle array of strings. Only thing it handles, other than primitive types, is byte array. I could not believe it. I though I was missing something. I can not overemphasise how this is very much unlike any prior experience I had with Go in the past. One of the reasons I like Go is no non-sense, everything just work. After wasting half a day trying to get it work, I explored [cgo](https://pkg.go.dev/cmd/cgo). This C interoperability tool. Though could just generate C headers and write native wrappers around those. However cgo appears to handle even less types.

## Solution to get to audit ready state
Most expedient solution was to rewrite [Bip39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki) and [Web3 Secret Storage](https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition) in Swift. As of 3AM last night this is pushed to master and ready to go to audit.

## Long term solution
I've worked with [Kotlin Multiplatform﻿](https://kotlinlang.org/docs/multiplatform.html) in the past. It is modern type safe language, binding are great and native feeling. Compiles to [WASM](https://webassembly.org/) as well. Plenty performant for that we need. One issue with it, its a bitch and half when it comes to new versions. Whenever Gradle or Android Studio or Kotlin has a new version, it breaks and takes couple of hours to get to compile. But what can you do. As for cryptographic primitives. We'll just use C reference implementations (same [Bitcoin Core﻿](https://bitcoin.org/en/bitcoin-core/) uses) with Kotlin wrappers.

### Closing note
I link to and explain crypto stuff code in both Go and Swift in audit notes. 



