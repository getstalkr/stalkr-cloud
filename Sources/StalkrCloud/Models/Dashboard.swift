//
//  Dashboard.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/6/17.
//
//

import Vapor
import FluentProvider
import Foundation

final class Dashboard: Model {
    
    var storage = Storage()
    
    struct Keys {
        static let id = Dashboard.idKey
        static let name = "name"
        static let configuration = "configuration"
    }
    
    var name: String
    var configuration: String
    
    init(name: String, configuration: String) {
        self.name = name
        self.configuration = configuration
    }
    
    required init(row: Row) throws {
        name = try row.get(Keys.name)
        configuration = try row.get(Keys.configuration)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.name, name)
        try row.set(Keys.configuration, configuration)
        return row
    }
    
    class func withName(_ name: String) throws -> Dashboard? {
        return try Dashboard.first(with: (Keys.name, .equals, name))
    }
}

// MARK: Preparations

extension Dashboard: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string(Keys.name)
            c.string(Keys.configuration)
        }
        
        try Dashboard(name: "admin", configuration: "Admin").save()
        try Dashboard(name: "user", configuration: "User").save()
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension Dashboard: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Keys.name),
            configuration: json.get(Keys.configuration)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.name, name)
        try json.set(Keys.configuration, configuration)
        return json
    }
}
