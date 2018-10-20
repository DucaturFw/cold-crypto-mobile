public final class HDWallet {
    
    public let masterPrivateKey: HDPrivateKey
    
    public init(seed: Data, network: Network) {
        self.masterPrivateKey = HDPrivateKey(seed: seed, network: network)
    }
    
    public func privateKey(at index: UInt32) throws -> PrivateKey {
        return try masterPrivateKey
            .derived(at: 44, hardens: true)
            .derived(at: 60, hardens: true)
            .derived(at: 0, hardens: true)
            .derived(at: 0)
            .derived(at: index)
            .privateKey()
    }
    
    public func address(at index: UInt32) throws -> String {
        return try privateKey(at: index).publicKey.address()
    }
    
    public func privateKey(at index: UInt32) throws -> String {
        return try privateKey(at: index).raw.toHexString()
    }
    
}
