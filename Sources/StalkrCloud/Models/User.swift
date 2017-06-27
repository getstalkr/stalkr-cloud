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
    
    struct Keys {
        static let id = User.idKey
        static let username = "username"
        static let password = "password"
    }
    
    var username: String
    var password: String
    
    public init(name: String, password: String) {
        self.username = name
        self.password = password
    }
    
    required init(row: Row) throws {
        username = try row.get(Keys.username)
        password = try row.get(Keys.password)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Keys.username, username)
        try row.set(Keys.password, password)
        return row
    }
}

// MARK: Preparations

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self) { c in
            c.id()
            c.string(Keys.username, length: nil,
                     optional: false, unique: true, default: nil)
            c.string(Keys.password)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: TokenAuthenticable

extension User: TokenAuthenticatable {
    public typealias TokenType = UserToken
}

// MARK: PasswordAuthenticatable

extension User: PasswordAuthenticatable {
    
    static var usernameKey: String {
        return Keys.username
    }
    
    static var passwordKey: String {
        return Keys.password
    }
    
    var hashedPassword: String? {
        return password
    }
    
    static var passwordVerifier: PasswordVerifier? {
        get { return _userPasswordVerifier }
        set { _userPasswordVerifier = newValue }
    }
    
    static func authenticate(password: Password) throws -> User {
        let name = password.username
        let pass = password.password
        
        if let user = try User.first(with: [(Keys.username, name),
                                            (Keys.password, pass)]) {
            return user
        }
        
        throw Abort.unauthorized
    }
}

private var _userPasswordVerifier: PasswordVerifier? = nil

// MARK: JSON

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get(Keys.username),
            password: json.get(Keys.password)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Keys.id, id)
        try json.set(Keys.username, username)
        try json.set(Keys.password, password)
        return json
    }
}

// MARK: ResponseRepresentable

extension User: ResponseRepresentable { }
