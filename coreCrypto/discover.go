// Copyright 2016 The go-ethereum Authors
// This file is part of the go-ethereum library.
//
// The go-ethereum library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-ethereum library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-ethereum library. If not, see <http://www.gnu.org/licenses/>.

// Contains all the wrappers from the accounts package to support client side enode
// management on mobile platforms.

package coreCrypto

import (
	"encoding/json"
	"errors"
	"github.com/ethereum/go-ethereum/core"
	"github.com/ethereum/go-ethereum/params"

	"github.com/ethereum/go-ethereum/p2p/enode"
)

// Enode represents a host on the network.
type Enode struct {
	node *enode.Node
}

// NewEnode parses a node designator.
//
// There are two basic forms of node designators
//   - incomplete nodes, which only have the public key (node ID)
//   - complete nodes, which contain the public key and IP/Port information
//
// For incomplete nodes, the designator must look like one of these
//
//	enode://<hex node id>
//	<hex node id>
//
// For complete nodes, the node ID is encoded in the username portion
// of the URL, separated from the host by an @ sign. The hostname can
// only be given as an IP address, DNS domain names are not allowed.
// The port in the host name section is the TCP listening port. If the
// TCP and UDP (discovery) ports differ, the UDP port is specified as
// query parameter "discport".
//
// In the following example, the node URL describes
// a node with IP address 10.3.58.6, TCP listening port 30303
// and UDP discovery port 30301.
//
//	enode://<hex node id>@10.3.58.6:30303?discport=30301
func NewEnode(rawurl string) (*Enode, error) {
	node, err := enode.Parse(enode.ValidSchemes, rawurl)
	if err != nil {
		return nil, err
	}
	return &Enode{node}, nil
}

// Enodes represents a slice of accounts.
type Enodes struct{ nodes []*enode.Node }

// NewEnodes creates a slice of uninitialized enodes.
func NewEnodes(size int) *Enodes {
	return &Enodes{
		nodes: make([]*enode.Node, size),
	}
}

// NewEnodesEmpty creates an empty slice of Enode values.
func NewEnodesEmpty() *Enodes {
	return NewEnodes(0)
}

// Size returns the number of enodes in the slice.
func (e *Enodes) Size() int {
	return len(e.nodes)
}

// Get returns the enode at the given index from the slice.
func (e *Enodes) Get(index int) (enode *Enode, _ error) {
	if index < 0 || index >= len(e.nodes) {
		return nil, errors.New("index out of bounds")
	}
	return &Enode{e.nodes[index]}, nil
}

// Set sets the enode at the given index in the slice.
func (e *Enodes) Set(index int, enode *Enode) error {
	if index < 0 || index >= len(e.nodes) {
		return errors.New("index out of bounds")
	}
	e.nodes[index] = enode.node
	return nil
}

// Append adds a new enode element to the end of the slice.
func (e *Enodes) Append(enode *Enode) {
	e.nodes = append(e.nodes, enode.node)
}

// MainnetGenesis returns the JSON spec to use for the main Ethereum network. It
// is actually empty since that defaults to the hard coded binary genesis block.
func MainnetGenesis() string {
	return ""
}

// RopstenGenesis returns the JSON spec to use for the Ropsten test network.
func RopstenGenesis() string {
	enc, err := json.Marshal(core.DefaultRopstenGenesisBlock())
	if err != nil {
		panic(err)
	}
	return string(enc)
}

// SepoliaGenesis returns the JSON spec to use for the Sepolia test network.
func SepoliaGenesis() string {
	enc, err := json.Marshal(core.DefaultSepoliaGenesisBlock())
	if err != nil {
		panic(err)
	}
	return string(enc)
}

// RinkebyGenesis returns the JSON spec to use for the Rinkeby test network
func RinkebyGenesis() string {
	enc, err := json.Marshal(core.DefaultRinkebyGenesisBlock())
	if err != nil {
		panic(err)
	}
	return string(enc)
}

// GoerliGenesis returns the JSON spec to use for the Goerli test network
func GoerliGenesis() string {
	enc, err := json.Marshal(core.DefaultGoerliGenesisBlock())
	if err != nil {
		panic(err)
	}
	return string(enc)
}

// FoundationBootnodes returns the enode URLs of the P2P bootstrap nodes operated
// by the foundation running the V5 discovery protocol.
func FoundationBootnodes() *Enodes {
	nodes := &Enodes{nodes: make([]*enode.Node, len(params.MainnetBootnodes))}
	for i, url := range params.MainnetBootnodes {
		var err error
		nodes.nodes[i], err = enode.Parse(enode.ValidSchemes, url)
		if err != nil {
			panic("invalid node URL: " + err.Error())
		}
	}
	return nodes
}
