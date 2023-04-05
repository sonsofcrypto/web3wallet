// Copyright 2016 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

// Go support functions for generated Go bindings. This file is
// copied into the generated main package, and compiled along
// with the bindings.

//#cgo CFLAGS: -Wall -I/usr/lib/jvm/default/include -I/usr/lib/jvm/default/include/linux
//#include <jni.h>
//#include <stdlib.h>
//#include "seq.h"
import "C"

import (
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"unsafe"

	_ "golang.org/x/mobile/bind/java"
	_seq "golang.org/x/mobile/bind/seq"
)

func init() {
	_seq.FinalizeRef = func(ref *_seq.Ref) {
		refnum := ref.Bind_Num
		if refnum < 0 {
			panic(fmt.Sprintf("not a foreign ref: %d", refnum))
		}
		C.go_seq_dec_ref(C.int32_t(refnum))
	}
	_seq.IncForeignRef = func(refnum int32) {
		if refnum < 0 {
			panic(fmt.Sprintf("not a foreign ref: %d", refnum))
		}
		C.go_seq_inc_ref(C.int32_t(refnum))
	}
	// Workaround for issue #17393.
	signal.Notify(make(chan os.Signal), syscall.SIGPIPE)
}

// IncGoRef is called by foreign code to pin a Go object while its refnum is crossing
// the language barrier
//
//export IncGoRef
func IncGoRef(refnum C.int32_t) {
	_seq.Inc(int32(refnum))
}

func main() {}

// DestroyRef is called by Java to inform Go it is done with a reference.
//
//export DestroyRef
func DestroyRef(refnum C.int32_t) {
	_seq.Delete(int32(refnum))
}

// encodeString returns a copy of a Go string as a UTF16 encoded nstring.
// The returned data is freed in go_seq_to_java_string.
//
// encodeString uses UTF16 as the intermediate format. Note that UTF8 is an obvious
// alternative, but JNI only supports a C-safe variant of UTF8 (modified UTF8).
func encodeString(s string) C.nstring {
	n := C.int(len(s))
	if n == 0 {
		return C.nstring{}
	}
	// Allocate enough for the worst case estimate, every character is a surrogate pair
	worstCaseLen := 4 * len(s)
	utf16buf := C.malloc(C.size_t(worstCaseLen))
	if utf16buf == nil {
		panic("encodeString: malloc failed")
	}
	chars := (*[1<<30 - 1]uint16)(unsafe.Pointer(utf16buf))[: worstCaseLen/2 : worstCaseLen/2]
	nchars := _seq.UTF16Encode(s, chars)
	return C.nstring{chars: unsafe.Pointer(utf16buf), len: C.jsize(nchars * 2)}
}

// decodeString decodes a UTF8 encoded nstring to a Go string. The data
// in str is freed after use.
func decodeString(str C.nstring) string {
	if str.chars == nil {
		return ""
	}
	chars := (*[1<<31 - 1]byte)(str.chars)[:str.len]
	s := string(chars)
	C.free(str.chars)
	return s
}

// fromSlice converts a slice to a jbyteArray cast as a nbyteslice. If cpy
// is set, the returned slice is a copy to be free by go_seq_to_java_bytearray.
func fromSlice(s []byte, cpy bool) C.nbyteslice {
	if s == nil || len(s) == 0 {
		return C.nbyteslice{}
	}
	var ptr *C.jbyte
	n := C.jsize(len(s))
	if cpy {
		ptr = (*C.jbyte)(C.malloc(C.size_t(n)))
		if ptr == nil {
			panic("fromSlice: malloc failed")
		}
		copy((*[1<<31 - 1]byte)(unsafe.Pointer(ptr))[:n], s)
	} else {
		ptr = (*C.jbyte)(unsafe.Pointer(&s[0]))
	}
	return C.nbyteslice{ptr: unsafe.Pointer(ptr), len: n}
}

// toSlice takes a nbyteslice (jbyteArray) and returns a byte slice
// with the data. If cpy is set, the slice contains a copy of the data and is
// freed.
func toSlice(s C.nbyteslice, cpy bool) []byte {
	if s.ptr == nil || s.len == 0 {
		return nil
	}
	var b []byte
	if cpy {
		b = C.GoBytes(s.ptr, C.int(s.len))
		C.free(s.ptr)
	} else {
		b = (*[1<<31 - 1]byte)(unsafe.Pointer(s.ptr))[:s.len:s.len]
	}
	return b
}
