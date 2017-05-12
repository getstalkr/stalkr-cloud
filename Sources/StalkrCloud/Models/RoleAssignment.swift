//
//  RoleAssignment.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/9/17.
//
//

import Vapor
import FluentProvider
import Foundation

final class RoleAssignment: Model {
    static func make(for parameter: String) throws -> Self {
        fatalError("not implemented")
    }

    /// the unique key to use as a slug in route building
    static var uniqueSlug: String = "role_assignment"

    
    let storage = Storage()
    
    var id: Node?
    var roleid: Node
    var userid: Node
    
    init(roleid: Node, userid: Node) {
        self.roleid = roleid
        self.userid = userid
    }
    
    required init(node: Node) throws {
        self.roleid = try node.get("roleid")
        self.userid = try node.get("userid")
    }
    
    required init(row: Row) throws {
        id = try row.get("id")
        roleid = try row.get("roleid")
        userid = try row.get("userid")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("roleid", roleid)
        try row.set("userid", userid)
        
        return row
    }
}

// MARK: Preparations

extension RoleAssignment: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { users in
            
            users.id()
            
            let roleid = Field(name: "roleid", type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
            let userid = Field(name: "userid", type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
            
            users.field(roleid)
            users.field(userid)

            users.foreignKey(foreignIdKey: "roleid", referencesIdKey: "id", on: Role.self, name: nil)
            users.foreignKey(foreignIdKey: "userid", referencesIdKey: "id", on: User.self, name: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension RoleAssignment: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            roleid: json.get("roleid"),
            userid: json.get("userid")
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("roleid", roleid)
        try json.set("userid", userid)
        return json
    }
}

// MARK: User

extension RoleAssignment {
    func user() throws -> User? {
        return try User.makeQuery().filter("id", userid).all().first
    }
}

// MARK: Role

extension RoleAssignment {
    func role() throws -> Role? {
        return try Role.makeQuery().filter("id", roleid).all().first
    }
}
