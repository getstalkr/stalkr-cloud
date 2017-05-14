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

final class TeamMembership: Model {

    let storage = Storage()
    
    var teamid: Identifier
    var userid: Identifier
    
    init(teamid: Identifier, userid: Identifier) {
        self.teamid = teamid
        self.userid = userid
    }
    
    required init(row: Row) throws {
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
