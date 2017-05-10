//
//  Role.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/6/17.
//
//

import Vapor
import FluentProvider
import Foundation

final class Role: Model {
    
    var storage = Storage()
    
    var id: Node?
    var name: String
    var readableName: String
    
    init(name: String, readableName: String) {
        self.name = name
        self.readableName = readableName
    }
    
    required init(row: Row) throws {
        id = try row.get("id")
        name = try row.get("name")
        readableName = try row.get("readable_name")
    }
    
    required init(node: Node, in context: Context) throws {
        id = try node.get("id")
        name = try node.get("name")
        readableName = try node.get("readable_name")
    }
    
    func makeRow() throws -> Row {
        
        var row = Row()
        
        try row.set("id", id)
        try row.set("name", name)
        try row.set("readable_name", readableName)
        
        return row
    }
    
    func makeNode(context: Context) throws -> Node {
        
        var node = Node([:], in: context)
        
        try node.set("id", id)
        try node.set("name", name)
        try node.set("readable_name", readableName)
        
        return node
    }
    
    class func withName(_ name: String) throws -> Role? {
        return try Role.makeQuery().filter("name", name).first()
    }
}

// MARK: Preparations

extension Role: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { roles in
            roles.id()
            roles.string("name", length: nil, optional: false, unique: true, default: nil)
            roles.string("readable_name")
        }
        
        try Role(name: "admin", readableName: "Admin").save()
        try Role(name: "user", readableName: "User").save()
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Role: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            readableName: json.get("readable_name")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("readable_name", readableName)
        return json
    }
}