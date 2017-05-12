//
//  TeamMembership.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/5/17.
//
//

import JWT
import Vapor
import FluentProvider
import Foundation

final class TeamMembership: Model, NodeConvertible {
    static func make(for parameter: String) throws -> Self {
        fatalError("not implemented")
    }

    /// the unique key to use as a slug in route building
    static var uniqueSlug: String = "team_membership"


    let storage = Storage()
    
    var id: Node?
    var teamid: Node
    var userid: Node
    
    init(teamid: Node, userid: Node) {
        self.teamid = teamid
        self.userid = userid
    }
    
    required init(node: Node) throws {
        self.teamid = try node.get("teamid")
        self.userid = try node.get("userid")
    }
    
    required init(row: Row) throws {
        id = try row.get("id")
        teamid = try row.get("teamid")
        userid = try row.get("userid")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("id", id)
        try row.set("teamid", teamid)
        try row.set("userid", userid)
        
        return row
    }
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set("id", id)
        try node.set("teamid", teamid)
        try node.set("userid", userid)
        
        return node
    }
}

// Preparations

extension TeamMembership: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { users in
            
            users.id()
            
            let teamid = Field(name: "teamid", type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
            let userid = Field(name: "userid", type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
        
            users.field(teamid)
            users.field(userid)
            
            users.foreignKey(foreignIdKey: "teamid", referencesIdKey: "id", on: Team.self, name: nil)
            users.foreignKey(foreignIdKey: "userid", referencesIdKey: "id", on: User.self, name: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
