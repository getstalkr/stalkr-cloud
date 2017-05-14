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
    static func make(for parameter: String) throws -> Self {
        fatalError("not implemented")
    }

    /// the unique key to use as a slug in route building
    static var uniqueSlug: String = "role"

    
    var storage = Storage()
    
    var name: String
    var readableName: String
    
    init(name: String, readableName: String) {
        self.name = name
        self.readableName = readableName
    }
    
    required init(row: Row) throws {
        name = try row.get("name")
        readableName = try row.get("readable_name")
    }
    
    func makeRow() throws -> Row {
        
        var row = Row()
        
        try row.set("id", id)
        try row.set("name", name)
        try row.set("readable_name", readableName)
        
        return row
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
