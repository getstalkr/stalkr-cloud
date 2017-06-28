//
//  Entity+Assert.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/24/17.
//
//

import Fluent
import MoreFluent
import Foundation

enum EntityAssertError: Error {
    case notFoundForId(e: Entity.Type, id: NodeRepresentable)
    case notFoundWithFilters(e: Entity.Type, filters: [MoreFilter])
    case foundWithFilters(e: Entity.Type, filters: [MoreFilter])
}

extension EntityAssertError: Debuggable {
    public var identifier: String {
        switch self {
        case .notFoundForId(_, _):
            return "notFoundForId"
        case .notFoundWithFilters(_, _):
            return "notFoundWithFilters"
        case .foundWithFilters(_, _):
            return "foundWithFilters"
        }
    }
    
    public var reason: String {
        switch self {
        case .notFoundForId(let e, let id):
            return "entity \(e.name) not found for id: \(id)"
        case .notFoundWithFilters(let e, let filters):
            return "entity \(e.name) not found with filters: \(filters)"
        case .foundWithFilters(let e, let filters):
            return "entity \(e.name) found with filters: \(filters)"
        }
    }
    
    public var possibleCauses: [String] {
        return []
    }
    
    public var suggestedFixes: [String] {
        return []
    }
}

extension Entity {
    
    public static func assertFind(_ id: NodeRepresentable) throws -> Self {
        if let e = try Self.find(id) {
            return e
        }
        
        throw EntityAssertError.notFoundForId(e: self, id: id)
    }
    
    public static func assertFirst(with filters: [MoreFilter]) throws -> Self {
        if let e = try Self.first(with: filters) {
            return e
        }
        
        throw EntityAssertError.notFoundWithFilters(e: self, filters: filters)
    }
    
    public static func assertFirst(with filters: MoreFilter...) throws -> Self {
        return try assertFirst(with: filters)
    }
    
    public static func assertNoFirst(with filters: [MoreFilter]) throws {
        if try Self.first(with: filters) != nil {
            throw EntityAssertError.foundWithFilters(e: self, filters: filters)
        }
    }
    
    public static func assertNoFirst(with filters: MoreFilter...) throws {
        try assertNoFirst(with: filters)
    }
}
