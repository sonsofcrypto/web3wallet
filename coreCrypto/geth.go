// Minimal wrapper around `github.com/ethereum/go-ethereum/mobile` needed to
// start, stop and configure LES node.

package coreCrypto

import (
	"fmt"
	geth "github.com/ethereum/go-ethereum/mobile"
	"log"
)

type NodeConfig struct {
	config *geth.NodeConfig
}

// NewNodeConfig creates a new node option set, initialized to the default values.
func NewNodeConfig() *NodeConfig {
	return &NodeConfig{geth.NewNodeConfig()}
}

type Node struct {
	node *geth.Node
}

// NewGethNode creates and configures a new Geth node.
func NewGethNode(datadir string, config *NodeConfig) (stack *Node, _ error) {
	gethNode, err := geth.NewNode(datadir, config.config)
	if err != nil {
		return nil, err
	}
	return &Node{gethNode}, nil
}

// NewGethNodeFataln creates and configures a new Geth node.
func NewGethNodeFataln(datadir string, config *NodeConfig) (stack *Node) {
	node, err := NewGethNode(datadir, config)
	if err != nil {
		log.Fatalln("Failed to instantiate geth node", err)
	}
	return node
}

// Close terminates a running node along with all it's services, tearing
// internal state down. It is not possible to restart a closed node.
func (n *Node) Close() error {
	return n.node.Close()
}

// Start creates a live P2P node and starts running it.
func (n *Node) Start() error {
	// TODO: recreate the node so it can be started multiple times
	return n.node.Start()
}

// GetNodeInfo gathers and returns a collection of metadata known about the host.
func (n *Node) GetNodeInfo() *NodeInfo {
	return &NodeInfo{n.node.GetNodeInfo()}
}

// GetPeersInfo returns an array of metadata objects describing connected peers.
func (n *Node) GetPeersInfo() *PeerInfos {
	return &PeerInfos{n.node.GetPeersInfo()}
}

// NodeInfo represents pi short summary of the information known about the host.
type NodeInfo struct {
	info *geth.NodeInfo
}

// String implements fmt.Stringer
func (ni *NodeInfo) String() string {
	return fmt.Sprintf("NodeInfo{\nid: %s\n", ni.info.GetID()) +
		fmt.Sprintf("name: %s\n", ni.info.GetName()) +
		fmt.Sprintf("enode: %s\n", ni.info.GetEnode()) +
		fmt.Sprintf("iP: %s\n", ni.info.GetIP()) +
		fmt.Sprintf("discovery port: %d\n", ni.info.GetDiscoveryPort()) +
		fmt.Sprintf("listener port: %d\n", ni.info.GetListenerPort()) +
		fmt.Sprintf("listener address: %s\n", ni.info.GetListenerAddress()) +
		fmt.Sprintf("protocols: %s\n}", ni.info.GetProtocols())
}

// PeerInfos represents a slice of infos about remote peers.
type PeerInfos struct {
	infos *geth.PeerInfos
}

// String implements fmt.Stringer
func (pi *PeerInfos) String() string {
	if pi.infos.Size() == 0 {
		return "PeerInfos{[]}"
	}
	str := "PeerInfos{["
	for i := 0; i < pi.infos.Size(); i++ {
		if peer, err := pi.infos.Get(i); err != nil {
			str += fmt.Sprintf("id: %v\n", peer.GetID())
			str += fmt.Sprintf("name: %v\n", peer.GetName())
			str += fmt.Sprintf("caps: %v\n", peer.GetCaps())
			str += fmt.Sprintf("local address: %v\n", peer.GetLocalAddress())
			str += fmt.Sprintf("remote address: %v\n", peer.GetRemoteAddress())
		}
	}
	str += "]}"
	return str
}
