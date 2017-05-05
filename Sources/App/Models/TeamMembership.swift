//
//  TeamMembership.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/5/17.
//
//

import JWT
import Vapor
import Fluent
import Foundation

class TeamMembership: Model {
    
    var id: Node?
    var teamid: Node
    var userid: Node
    
    
    init(teamid: Node, userid: Node) {
        self.teamid = teamid
        self.userid = userid
    }
    
    required init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        teamid = try node.extract("teamid")
        userid = try node.extract("userid")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "teamid": teamid,
            "userid": userid
            ])
    }
}

// Preparations

extension TeamMembership: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create("team_memberships") { users in
            users.id()
            users.id("teamid", optional: false, unique: true, default: nil)
            users.id("userid", optional: false, unique: true, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}
