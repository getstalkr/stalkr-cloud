//
//  UserToken.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 6/16/17.
//
//

import Crypto
import Foundation
import FluentProvider

final class UserToken: Model {

    let storage: Storage = Storage()
    
    struct Keys {
        static let id = UserToken.idKey
        static let token = "token"
        static let userId = User.foreignIdKey
    }
    
    let token: String
    let userId: Identifier
    
    init(string: String, user: User) throws {
        token = string
        userId = try user.assertExists()
    }
    
    init(row: Row) throws {
        token = try row.get(Keys.token)
        userId = try row.get(Keys.userId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.token, token)
        try row.set(Keys.userId, userId)
        return row
    }
}

// MARK: Convenience

extension UserToken {
    
    /// Generates a new token for the supplied User.
    static func generate(for user: User) throws -> UserToken {
        // generate 128 random bits using OpenSSL
        let random = try Crypto.Random.bytes(count: 16)
        
        // create and return the new token
        return try UserToken(string: random.base64Encoded.makeString(), user: user)
    }
}

// MARK: Relations

extension UserToken {
    var user: Parent<UserToken, User> {
        return parent(id: userId)
    }
}

// MARK: Preparation

extension UserToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string(Keys.token)
            c.foreignId(for: User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

extension UserToken: JSONConvertible {
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
        return json
    }
}

// MARK: ResponseRepresentable

extension UserToken: ResponseRepresentable { }
