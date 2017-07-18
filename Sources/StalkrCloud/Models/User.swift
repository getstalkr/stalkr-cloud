//
//  User.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/4/17.
//
//

import JWT
import Vapor
import AuthProvider
import FluentProvider
import Foundation

final class User: Model {
    
    let storage = Storage()
    
    var username: String
    var password: String
    
    var roles: UserRoles
    
    var shortToken = ShortToken()
    
    public init(name: String, password: String, roles: UserRoles = .user) {
        self.username = name
        self.password = password
        self.roles = roles
    }
    
    required init(row: Row) throws {
        username = try row.get("username")
        password = try row.get("password")
        roles = UserRoles(rawValue: try row.get("roles"))
        
        shortToken.secret = try row.get("short_token_secret")
        shortToken.expiration = try row.get("short_token_expiration")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("username", username)
        try row.set("password", password)
        try row.set("roles", roles.rawValue)
        try row.set("short_token_secret", shortToken.secret)
        try row.set("short_token_expiration", shortToken.expiration)
        return row
    }
}

// MARK: Preparations

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string("username", length: nil,
                     optional: false, unique: true, default: nil)
            c.string("password")
            c.int("roles")
            c.string("short_token_secret", length: ShortToken.length, optional: true, unique: true, default: nil)
            c.date("short_token_expiration", optional: true, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: RoleAssignable

struct UserRoles: Roles {
    var rawValue: UInt
    
    static let user = UserRoles(index: 0)
    static let admin = UserRoles(index: 1)
    static let all: UserRoles = [.user, .admin]
}

extension User: RolesAssignable {
    typealias RolesType = UserRoles
}

// MARK: TokenAuthenticable

extension User: TokenAuthenticatable {
    public typealias TokenType = UserToken
}

// MARK: PasswordAuthenticatable

extension User: PasswordAuthenticatable {
    static var usernameKey: String {
        return "username"
    }
    
    static var passwordKey: String {
        return "password"
    }
    
    static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
    
    static func authenticate(password: Password) throws -> User {
        let name = password.username
        let pass = password.password
        
        if let user = try User.first(with: [("username", .equals, name),
                                            ("password", .equals, pass)]) {
            return user
        }
        
        throw Abort.unauthorized
    }
    
    var hashedPassword: String? {
        return password
    }
}

private var _userPasswordVerifier: PasswordVerifier? = nil

// MARK: JSON

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("username"),
            password: json.get("password")
        )
        
        shortToken.secret = try? json.get("short_token_secret")
        shortToken.expiration = try? json.get("short_token_expiration")
    }
    
    func makeJSON() throws -> JSON {
        return try self.makeJSON(keys: "id", "username", "password")
    }
    
    func makeJSON(keys: String...) throws -> JSON {
        var json = JSON()
        if keys.contains("id") {
            try json.set("id", id)
        }
        if keys.contains("username") {
            try json.set("username", username)
        }
        if keys.contains("password") {
            try json.set("password", password)
        }
        if keys.contains("roles") {
            try json.set("roles", roles.rawValue)
        }
        if keys.contains("short_token_secret") {
            try json.set("short_token_secret", shortToken.secret)
        }
        if keys.contains("short_token_expiration") {
            try json.set("short_token_expiration", shortToken.expiration)
        }
        return json
    }
}

// MARK: ResponseRepresentable

extension User: ResponseRepresentable { }

// MARK: ShortToken

extension User {
    static func makeUniqueShortToken() throws -> ShortToken {
        let maxAttempts = 30
        
        for _ in (0..<maxAttempts) {
            let secret = ShortToken.makeSecret()
            
            if try User.first(with: ("short_token_secret", .equals, secret)) == nil {
                return ShortToken(secret: secret, expiration: ShortToken.makeExpiration())
            }
        }
        
        throw Abort.serverError
    }
}
