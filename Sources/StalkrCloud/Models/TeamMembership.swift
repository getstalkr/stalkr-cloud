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
    
    struct Keys {
        static let id = TeamMembership.idKey
        static let teamId = Team.foreignIdKey
        static let userId = User.foreignIdKey
    }
    
    var teamId: Identifier
    var userId: Identifier
    
    init(teamId: Identifier, userId: Identifier) {
        self.teamId = teamId
        self.userId = userId
    }
    
    required init(row: Row) throws {
        teamId = try row.get(Keys.teamId)
        userId = try row.get(Keys.userId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.teamId, teamId)
        try row.set(Keys.userId, userId)
        return row
    }
}

// MARK: Relations

extension TeamMembership {
    var team: Parent<TeamMembership, Team> {
        return parent(id: teamId)
    }
    
    var user: Parent<TeamMembership, User> {
        return parent(id: userId)
    }
}

extension Team {
    var teamMemberships: Children<Team, TeamMembership> {
        return children()
    }
}

extension User {
    var teamMemberships: Children<User, TeamMembership> {
        return children()
    }
}

// Preparations

extension TeamMembership: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            
            let teamId = Field(name: Keys.teamId, type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
            
            let userId = Field(name: Keys.userId, type: .int, optional: false,
                               unique: false, default: nil, primaryKey: true)
            
            c.field(teamId)
            c.field(userId)
            
            c.foreignKey(for: Team.self)
            c.foreignKey(for: User.self)
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
        try json.set(Keys.id, self.id)
        try json.set(Keys.teamId, self.teamId)
        try json.set(Keys.userId, self.userId)
        return json
    }
}

// MARK: ResponseRepresentable

extension TeamMembership: ResponseRepresentable { }
