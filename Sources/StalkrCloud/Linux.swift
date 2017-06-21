//
//  Linux.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 6/21/17.
//
//

#if os(Linux)
    import SwiftGlibc
    
    public func arc4random_uniform(_ max: UInt32) -> Int32 {
        return (SwiftGlibc.rand() % Int32(max-1))
    }
#endif
