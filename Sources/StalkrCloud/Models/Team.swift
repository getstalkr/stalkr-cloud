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
    
    struct Keys {
        static let id = Team.idKey
        static let name = "name"
    }

    var name: String
    
    init(name: String) {
        self.name = name
    }
    
    required init(row: Row) throws {
        name = try row.get(Keys.name)
    }
    
    required init(node: Node, in context: Context) throws {
        name = try node.get(Keys.name)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        return row
    }
}

// Preparations

extension Team: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string(Keys.name, length: nil,
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
            name: json.get(Keys.name)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.name, name)
        return json
    }
}

// MARK: ResponseRepresentable

extension Team: ResponseRepresentable { }
