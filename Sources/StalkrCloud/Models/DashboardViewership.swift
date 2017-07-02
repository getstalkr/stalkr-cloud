//
//  DashboardViewership.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 7/2/17.
//
//

import Vapor
import FluentProvider
import Foundation

final class DashboardViewership: Model {
    
    let storage = Storage()
    
    struct Keys {
        static let id = DashboardViewership.idKey
        static let dashboardId = Dashboard.foreignIdKey
        static let userId = User.foreignIdKey
    }
    
    var dashboardId: Identifier
    var userId: Identifier
    
    init(dashboardId: Identifier, userId: Identifier) {
        self.dashboardId = dashboardId
        self.userId = userId
    }
    
    required init(row: Row) throws {
        dashboardId = try row.get(Keys.dashboardId)
        userId = try row.get(Keys.userId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.dashboardId, dashboardId)
        try row.set(Keys.userId, userId)
        return row
    }
}

// MARK: Relations

extension DashboardViewership {
    var dashboard: Parent<DashboardViewership, Dashboard> {
        return parent(id: dashboardId)
    }
    
    var user: Parent<DashboardViewership, User> {
        return parent(id: userId)
    }
}

extension Dashboard {
    var dashboardViewerships: Children<Dashboard, DashboardViewership> {
        return children()
    }
}

extension User {
    var dashboardViewerships: Children<User, DashboardViewership> {
        return children()
    }
}

// MARK: Preparations

extension DashboardViewership: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            
            c.parent(Dashboard.self, optional: false, unique: false, foreignIdKey: Dashboard.foreignIdKey)
            c.parent(User.self, optional: false, unique: false, foreignIdKey: User.foreignIdKey)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension DashboardViewership: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            dashboardId: json.get(Keys.dashboardId),
            userId: json.get(Keys.userId)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.dashboardId, dashboardId)
        try json.set(Keys.userId, userId)
        return json
    }
}

// MARK: ResponseRepresentable

extension DashboardViewership: ResponseRepresentable { }
