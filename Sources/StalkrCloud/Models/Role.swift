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
    
    struct Keys {
        static let id = Role.idKey
        static let name = "name"
        static let readableName = "readable_name"
    }
    
    var name: String
    var readableName: String
    
    init(name: String, readableName: String) {
        self.name = name
        self.readableName = readableName
    }
    
    required init(row: Row) throws {
        name = try row.get(Keys.name)
        readableName = try row.get(Keys.readableName)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.readableName, readableName)
        return row
    }
    
    class func withName(_ name: String) throws -> Role? {
        return try Role.first(with: (Keys.name, name))
    }
}

// MARK: Preparations

extension Role: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string(Keys.name, length: nil, optional: false, unique: true, default: nil)
            c.string(Keys.readableName)
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
            name: json.get(Keys.name),
            readableName: json.get(Keys.readableName)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.name, name)
        try json.set(Keys.readableName, readableName)
        return json
    }
}
