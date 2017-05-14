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

    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    required init(row: Row) throws {
        name = try row.get("name")
    }
    
    required init(node: Node, in context: Context) throws {
        name = try node.get("name")
    }
    
    func makeRow() throws -> Row {
        
        var row = Row()
        
        try row.set("id", id)
        try row.set("name", name)
        
        return row
    }
    
    func makeNode(context: Context) throws -> Node {
        
        var node = Node([:], in: context)
        
        try node.set("id", id)
        try node.set("name", name)
        
        return node
    }
}

// Preparations

extension Team: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
