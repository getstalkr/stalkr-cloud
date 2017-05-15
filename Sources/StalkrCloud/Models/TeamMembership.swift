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
        
        try database.create(self) { c in
            
            c.id()
            
            let teamid = Field(name: "teamid", type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
            let userid = Field(name: "userid", type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
        
            c.field(teamid)
            c.field(userid)
            
            c.foreignKey(foreignIdKey: "teamid", referencesIdKey: "id", on: Team.self, name: nil)
            c.foreignKey(foreignIdKey: "userid", referencesIdKey: "id", on: User.self, name: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSONRepresentable

extension TeamMembership: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        
        try json.set("id", self.id)
        try json.set("teamid", self.teamid)
        try json.set("userid", self.userid)
        
        return json
    }
}

// MARK: Team

extension TeamMembership {
    func team() throws -> Team? {
        return try Team.find(teamid)
    }
}

// MARK: User

extension TeamMembership {
    func user() throws -> User? {
        return try User.find(userid)
    }
}
