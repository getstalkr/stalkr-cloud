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
    
    struct Keys {
        static let id = RoleAssignment.idKey
        static let roleId = Role.foreignIdKey
        static let userId = User.foreignIdKey
    }
    
    var roleId: Identifier
    var userId: Identifier
    
    init(roleId: Identifier, userId: Identifier) {
        self.roleId = roleId
        self.userId = userId
    }
    
    required init(row: Row) throws {
        roleId = try row.get(Keys.roleId)
        userId = try row.get(Keys.userId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.roleId, roleId)
        try row.set(Keys.userId, userId)
        return row
    }
}

// MARK: Relations

extension RoleAssignment {
    var role: Parent<RoleAssignment, Role> {
        return parent(id: roleId)
    }
    
    var user: Parent<RoleAssignment, User> {
        return parent(id: userId)
    }
}

extension Role {
    var roleAssignments: Children<Role, RoleAssignment> {
        return children()
    }
}

extension User {
    var roleAssignments: Children<User, RoleAssignment> {
        return children()
    }
}

// MARK: Preparations

extension RoleAssignment: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            
            c.parent(Role.self, optional: false, unique: false, foreignIdKey: Role.foreignIdKey)
            c.parent(User.self, optional: false, unique: false, foreignIdKey: User.foreignIdKey)
            //let roleId = Field(name: Keys.roleId, type: .int, optional: false,
            //                   unique: false, default: nil, primaryKey: true)
            
            //let userId = Field(name: Keys.userId, type: .int, optional: false,
                            //unique: false, default: nil, primaryKey: true)
            
            //c.field(roleId)
            //c.field(userId)
            
            //c.foreignKey(for: Role.self)
            //c.foreignKey(for: User.self)
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
            roleId: json.get(Keys.roleId),
            userId: json.get(Keys.userId)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.roleId, roleId)
        try json.set(Keys.userId, userId)
        return json
    }
}

// MARK: ResponseRepresentable

extension RoleAssignment: ResponseRepresentable { }
