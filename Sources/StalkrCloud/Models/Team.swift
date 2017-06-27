//
//  Team.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/5/17.
//
//

import JWT
import Vapor
import FluentProvider
import Foundation

final class Team: Model {

    var storage = Storage()
    
    struct Properties {
        static let name = "name"
    }

    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    required init(row: Row) throws {
        name = try row.get(Properties.name)
    }
    
    required init(node: Node, in context: Context) throws {
        name = try node.get(Properties.name)
    }
    
    func makeRow() throws -> Row {
        
        var row = Row()
        
        try row.set("id", id)
        try row.set(Properties.name, name)
        
        return row
    }
    
    func makeNode(context: Context) throws -> Node {
        
        var node = Node([:], in: context)
        
        try node.set("id", id)
        try node.set(Properties.name, name)
        
        return node
    }
}

// Preparations

extension Team: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string(Properties.name, length: nil,
                     optional: false, unique: true, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Team: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Properties.name)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set(Properties.name, name)
        return json
    }
}

// MARK: ResponseRepresentable

extension Team: ResponseRepresentable { }
