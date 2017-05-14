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
    
    let storage = Storage()
    
    var roleid: Identifier
    var userid: Identifier
    
    init(roleid: Identifier, userid: Identifier) {
        self.roleid = roleid
        self.userid = userid
    }
    
    required init(row: Row) throws {
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
