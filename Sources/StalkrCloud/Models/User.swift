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
    
    struct Properties {
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
        username = try row.get(Properties.username)
        password = try row.get(Properties.password)
    }
    
    func makeRow() throws -> Row {
        
        var row = Row()
        try row.set("id", id)
        try row.set(Properties.username, username)
        try row.set(Properties.password, password)
        
        return row
    }
}

// MARK: Preparations

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { c in
            c.id()
            c.string(Properties.username, length: nil,
                     optional: false, unique: true, default: nil)
            c.string(Properties.password)
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
        return "username"
    }
    
    static var passwordKey: String {
        return "password"
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
        
        if let user = try User.first(with: [(Properties.username, name),
                                            (Properties.password, pass)]) {
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
            name: json.get(Properties.username),
            password: json.get(Properties.password)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set(Properties.username, username)
        try json.set(Properties.password, password)
        return json
    }
}

// MARK: ResponseRepresentable

extension User: ResponseRepresentable { }
