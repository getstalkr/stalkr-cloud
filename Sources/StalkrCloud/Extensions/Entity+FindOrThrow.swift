//
//  Entity+FindOrThrow.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/24/17.
//
//

import Fluent
import Foundation

extension Entity {
    public static func findOrThrow(_ id: NodeRepresentable) throws -> Self {
        if let e = try Self.find(id) {
            return e
        }
        
        throw QueryError.invalidDriverResponse("\(Self.name) not found for id: \(id)")
    }
}
