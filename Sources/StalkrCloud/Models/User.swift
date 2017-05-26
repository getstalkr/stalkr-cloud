//
//  User.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/4/17.
//
//

import JWT
import Vapor
import FluentProvider
import Foundation

final class User: Model {

    let storage = Storage()
    
    var username: String
    var password: String
    var token: String?
    
    public init(name: String, password: String) {
        self.username = name
        self.password = password
    }
    
    required init(row: Row) throws {
        username = try row.get("username")
        password = try row.get("password")
        token = try row.get("token")
    }
    
    func makeRow() throws -> Row {
        
        var row = Row()
        try row.set("id", id)
        try row.set("username", username)
        try row.set("password", password)
        try row.set("token", token)
        
        return row
    }
    
    func createToken() throws -> String {
        let payload = try Node(node: ["user": id])
        let jwt = try JWT(payload: JSON(payload), signer: HS256(key: "jwtkey".makeBytes()))
        
        let token = try jwt.createToken()
        self.token = token
        try self.save()
        return token
    }
}

// MARK: Preparations

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { c in
            c.id()
            c.string("username", length: nil, optional: false, unique: true, default: nil)
            c.string("password")
            c.string("token", length: nil, optional: true, unique: false, default: nil)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
