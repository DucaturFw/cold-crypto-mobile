//
//  AddressChecker.swift
//  MultiMask
//
//  Created by Kirill Kozhuhar on 12/08/2018.
//  Copyright © 2018 Kirill Kozhuhar. All rights reserved.
//

import Foundation
import CryptoSwift

extension CharacterSet {
    
    static var hexadecimalNumbers: CharacterSet {
        return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    }
    static var hexadecimalLetters: CharacterSet {
        return [
            "a", "b", "c", "d", "e", "f",
            "A", "B", "C", "D", "E", "F"
        ]
    }
    static var hexadecimals: CharacterSet {
        return hexadecimalNumbers.union(hexadecimalLetters)
    }
}

public typealias Byte  = UInt8
public typealias Bytes = [Byte]

public struct EthereumAddress {
    
    public static func isValid(address key: String) -> String? {
        let tmp: String
        if let r = key.range(of: "ethereum:") {
            tmp = key.replacingCharacters(in: r, with: "")
        } else {
            tmp = key
        }
        if let address = try? EthereumAddress(hex: tmp, eip55: true) {
            return address.hex(eip55: true)
        } else if let address = try? EthereumAddress(hex: tmp, eip55: false) {
            return address.hex(eip55: false)
        }
        return nil
    }
    
    // MARK: - Properties
    /// The raw address bytes
    public let rawAddress: Bytes
    
    // MARK: - Initialization
    /**
     * Initializes this instance of `EthereumAddress` with the given `hex` String.
     *
     * `hex` must be either 40 characters (20 bytes) or 42 characters (with the 0x hex prefix) long.
     *
     * If `eip55` is set to `true`, a checksum check will be done over the given hex string as described
     * in https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
     *
     * - parameter hex: The ethereum address as a hex string. Case sensitive iff `eip55` is set to true.
     * - parameter eip55: Whether to check the checksum as described in eip 55 or not.
     *
     * - throws: EthereumAddress.Error.addressMalformed if the given hex string doesn't fulfill the conditions described above.
     *           EthereumAddress.Error.checksumWrong iff `eip55` is set to true and the checksum is wrong.
     */
    public init(hex: String, eip55: Bool) throws {
        // Check length
        guard hex.count == 40 || hex.count == 42 else {
            throw Error.addressMalformed
        }
        
        var hex = hex
        
        // Check prefix
        if hex.count == 42 {
            let s = hex.index(hex.startIndex, offsetBy: 0)
            let e = hex.index(hex.startIndex, offsetBy: 2)
            
            guard String(hex[s..<e]) == "0x" else {
                throw Error.addressMalformed
            }
            
            // Remove prefix
            let hexStart = hex.index(hex.startIndex, offsetBy: 2)
            hex = String(hex[hexStart...])
        }
        
        // Check hex
        guard hex.rangeOfCharacter(from: CharacterSet.hexadecimals.inverted) == nil else {
            throw Error.addressMalformed
        }
        
        // Create address bytes
        var addressBytes = Bytes()
        for i in stride(from: 0, to: hex.count, by: 2) {
            let s = hex.index(hex.startIndex, offsetBy: i)
            let e = hex.index(hex.startIndex, offsetBy: i + 2)
            
            guard let b = Byte(String(hex[s..<e]), radix: 16) else {
                throw Error.addressMalformed
            }
            addressBytes.append(b)
        }
        self.rawAddress = addressBytes
        
        // EIP 55 checksum
        // See: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
        if eip55 {
            let hash = SHA3(variant: .keccak256).calculate(for: Array(hex.lowercased().utf8))
            
            for i in 0..<hex.count {
                let charString = String(hex[hex.index(hex.startIndex, offsetBy: i)])
                if charString.rangeOfCharacter(from: CharacterSet.hexadecimalNumbers) != nil {
                    continue
                }
                
                let bytePos = (4 * i) / 8
                let bitPos = (4 * i) % 8
                guard bytePos < hash.count && bitPos < 8 else {
                    throw Error.addressMalformed
                }
                let bit = (hash[bytePos] >> (7 - UInt8(bitPos))) & 0x01
                
                if charString.lowercased() == charString && bit == 1 {
                    throw Error.checksumWrong
                } else if charString.uppercased() == charString && bit == 0 {
                    throw Error.checksumWrong
                }
            }
        }
    }
    
    /**
     * Initializes a new instance of `EthereumAddress` with the given raw Bytes array.
     *
     * `rawAddress` must be exactly 20 bytes long.
     *
     * - parameter rawAddress: The raw address as a byte array.
     *
     * - throws: EthereumAddress.Error.addressMalformed if the rawAddress array is not 20 bytes long.
     */
    public init(rawAddress: Bytes) throws {
        guard rawAddress.count == 20 else {
            throw Error.addressMalformed
        }
        self.rawAddress = rawAddress
    }
    
    // MARK: - Convenient functions
    /**
     * Returns this ethereum address as a hex string.
     *
     * Adds the EIP 55 mixed case checksum if `eip55` is set to true.
     *
     * - parameter eip55: Whether to add the mixed case checksum as described in eip 55.
     *
     * - returns: The hex string representing this `EthereumAddress`.
     *            Either lowercased or mixed case (checksumed) depending on the parameter `eip55`.
     */
    public func hex(eip55: Bool) -> String {
        var hex = "0x"
        if !eip55 {
            for b in rawAddress {
                hex += String(format: "%02x", b)
            }
        } else {
            var address = ""
            for b in rawAddress {
                address += String(format: "%02x", b)
            }
            let hash = SHA3(variant: .keccak256).calculate(for: Array(address.utf8))
            
            for i in 0..<address.count {
                let charString = String(address[address.index(address.startIndex, offsetBy: i)])
                
                if charString.rangeOfCharacter(from: CharacterSet.hexadecimalNumbers) != nil {
                    hex += charString
                    continue
                }
                
                let bytePos = (4 * i) / 8
                let bitPos = (4 * i) % 8
                let bit = (hash[bytePos] >> (7 - UInt8(bitPos))) & 0x01
                
                if bit == 1 {
                    hex += charString.uppercased()
                } else {
                    hex += charString.lowercased()
                }
            }
        }
        
        return hex
    }
    
    // MARK: - Errors
    public enum Error: Swift.Error {
        case addressMalformed
        case checksumWrong
    }
}

// MARK: - Equatable
extension EthereumAddress: Equatable {
    public static func ==(_ lhs: EthereumAddress, _ rhs: EthereumAddress) -> Bool {
        return lhs.rawAddress == rhs.rawAddress
    }
}
