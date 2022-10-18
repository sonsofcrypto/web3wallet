// Minimal wrapper around `github.com/ethereum/go-ethereum/mobile` needed to
// start, stop and configure LES node.

package coreCrypto

import (
	"fmt"
	geth "github.com/ethereum/go-ethereum/mobile"
	"log"
)

// Enodes represents a slice of accounts.
type Enodes struct{ enodes *geth.Enodes }

// Enode represents a host on the network.
type Enode struct{ enode *geth.Enode }

// NodeConfig represents the collection of configuration values to fine tune the
// Geth node embedded into a mobile process. The available values are a subset
// of the entire API provided by go-ethereum to reduce the maintenance surface
// and dev complexity.
type NodeConfig struct {
	config *geth.NodeConfig
}

// BootstrapNodes used to establish connectivity with the rest of the network.
func (nc *NodeConfig) BootstrapNodes() *Enodes {
	return &Enodes{nc.config.BootstrapNodes}
}

// MaxPeers is the maximum number of peers that can be connected. If this is
// set to zero, then only the configured static and trusted peers can connect.
func (nc *NodeConfig) MaxPeers() int {
	return nc.config.MaxPeers
}

// SetMaxPeers is the maximum number of peers that can be connected. If this is
// set to zero, then only the configured static and trusted peers can connect.
func (nc *NodeConfig) SetMaxPeers(maxPeers int) {
	nc.config.MaxPeers = maxPeers
}

// EthereumEnabled specifies whether the node should run the Ethereum protocol.
func (nc *NodeConfig) EthereumEnabled() bool {
	return nc.config.EthereumEnabled
}

// SetEthereumEnabled specifies whether the node should run the Ethereum protocol.
func (nc *NodeConfig) SetEthereumEnabled(ethereumEnabled bool) {
	nc.config.EthereumEnabled = ethereumEnabled
}

// EthereumNetworkID is the network identifier used by the Ethereum protocol to
// decide if remote peers should be accepted or not.
func (nc *NodeConfig) EthereumNetworkID() int64 {
	return nc.config.EthereumNetworkID
}

// SetEthereumNetworkID is the network identifier used by the Ethereum protocol to
// decide if remote peers should be accepted or not.
func (nc *NodeConfig) SetEthereumNetworkID(networkID int64) {
	nc.config.EthereumNetworkID = networkID
}

// EthereumGenesis is the genesis JSON to use to seed the blockchain with. An
// empty genesis state is equivalent to using the mainnet's state.
func (nc *NodeConfig) EthereumGenesis() string {
	return nc.config.EthereumGenesis
}

// SetEthereumGenesis is the genesis JSON to use to seed the blockchain with. An
// empty genesis state is equivalent to using the mainnet's state.
func (nc *NodeConfig) SetEthereumGenesis(genesis string) {
	nc.config.EthereumGenesis = genesis
}

// EthereumDatabaseCache is the system memory in MB to allocate for database
// caching. A minimum of 16MB is always reserved.
func (nc *NodeConfig) EthereumDatabaseCache() int {
	return nc.config.EthereumDatabaseCache
}

// SetEthereumDatabaseCache is the system memory in MB to allocate for database
// caching. A minimum of 16MB is always reserved.
func (nc *NodeConfig) SetEthereumDatabaseCache(databaseCache int) {
	nc.config.EthereumDatabaseCache = databaseCache
}

// EthereumNetStats is a netstats connection string to use to report various
// chain, transaction and node stats to a monitoring server. It has the form
// "nodename:secret@host:port"
func (nc *NodeConfig) EthereumNetStats() string {
	return nc.config.EthereumNetStats
}

// SetEthereumNetStats is a netstats connection string to use to report various
// chain, transaction and node stats to a monitoring server. It has the form
// "nodename:secret@host:port"
func (nc *NodeConfig) SetEthereumNetStats(netStats string) {
	nc.config.EthereumNetStats = netStats
}

// PprofAddress listening address of pprof server.
func (nc *NodeConfig) PprofAddress() string {
	return nc.config.PprofAddress
}

// SetPprofAddress listening address of pprof server.
func (nc *NodeConfig) SetPprofAddress(pprofAddress string) {
	nc.config.PprofAddress = pprofAddress
}

// AddBootstrapNode adds a bootstrap node to the node config.
func (nc *NodeConfig) AddBootstrapNode(node *Enode) {
	nc.config.AddBootstrapNode(node.enode)
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
