//
//  SmartToken.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 6/21/17.
//
//

import Crypto
import Foundation
import FluentProvider

final class SmartToken: Model {
    
    let storage: Storage = Storage()
    
    struct Keys {
        static let id = SmartToken.idKey
        static let token = "token"
        static let userId = User.foreignIdKey
        static let expiration = "expiration"
    }
    
    let token: String
    let userId: Identifier
    let expiration: Date
    
    init(string: String, user: User) throws {
        token = string
        userId = try user.assertExists()
        expiration = Date().addingTimeInterval(600)
    }
    
    init(row: Row) throws {
        token = try row.get(Keys.token)
        userId = try row.get(Keys.userId)
        expiration = try row.get(Keys.expiration)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.token, token)
        try row.set(Keys.userId, userId)
        try row.set(Keys.expiration, expiration)
        return row
    }
}

// MARK: Convenience

extension SmartToken {
    
    /// Generates a new token for the supplied User.
    static func generate(for user: User) throws -> SmartToken {
        // generate 128 random bits using OpenSSL
        let random = String.random(length: 6).uppercased()
        
        // create and return the new token
        return try SmartToken(string: random, user: user)
    }
}

// MARK: Relations

extension SmartToken {
    var user: Parent<SmartToken, User> {
        return parent(id: id)
    }
}

// MARK: Preparation

extension SmartToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string(Keys.token)
            c.foreignId(for: User.self)
            c.date(Keys.expiration)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension SmartToken: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            string: json.get(Keys.token),
            user: json.get(Keys.userId)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.token, token)
        try json.set(Keys.userId, userId)
        try json.set(Keys.expiration, expiration)
        return json
    }
}

// MARK: ResponseRepresentable

extension SmartToken: ResponseRepresentable { }
