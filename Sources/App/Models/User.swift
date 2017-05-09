//
//  User.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/4/17.
//
//

import JWT
import Vapor
import FluentProvider
import Foundation

class User: Model {


    let storage = Storage()

    
    var id: Node?
    var username: String
    var password: String
    var token: String?
    
    
    init(name: String, password: String) {
        self.username = name
        self.password = password
    }
    
    required init(row: Row) throws {
        id = try row.get("id")
        username = try row.get("username")
        password = try row.get("password")
        token = try row.get("token")
    }
    
    func makeRow() throws -> Row {
        
        var row = Row()
        try row.set("id", id)
        try row.set("username", username)
        try row.set("password", password)
        try row.set("token", token)
        
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        
        var node = Node([:], in: context)
        
        try node.set("id", id)
        try node.set("username", username)
        try node.set("password", password)
        try node.set("token", token)
        
        return node
    }
    
    func createToken() throws -> String {
        let payload = try Node(node: ["user": id])
        let jwt = try JWT(payload: JSON(payload), signer: HS256(key: "jwtkey".makeBytes()))
        
        let token = try jwt.createToken()
        self.token = token
        try self.save()
        return token
    }
    
    class func withName(_ name: String) throws -> User? {
        return try User.makeQuery().filter("username", name).first()
    }
}

// MARK: Preparations

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { users in
            users.id()
            users.string("username", length: nil, optional: false, unique: true, default: nil)
            users.string("password")
            users.string("token", length: nil, optional: true, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Roles

extension User {
    func assignments() throws -> [RoleAssignment] {
        return try RoleAssignment.makeQuery().filter("userid", id).all()
    }
    
    @discardableResult
    func assign(role: Role) throws -> Bool {
        
        guard let roleid = role.id, let userid = self.id else {
            return false
        }
        
        let assignment = RoleAssignment(roleid: roleid, userid: userid)
        
        try assignment.save()
        
        return true
    }
}

// MARK: Teams

extension User {
    
    // TODO: list teams
    
    func join(team: Team) throws -> Bool {
        
        guard let teamid = team.id, let userid = self.id else {
            return false
        }
        
        let membership = TeamMembership(teamid: teamid, userid: userid)
        
        try membership.save()
        
        return true
    }
}
