//
//  Team.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/5/17.
//
//

import JWT
import Vapor
import Fluent
import Foundation

class Team: Model {

    var id: Node?
    var name: String

    
    init(name: String) {
        self.name = name
    }
    
    required init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name
            ])
    }
}

// Preparations

extension Team: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create("teams") { users in
            users.id()
            users.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("teams")
    }
}
