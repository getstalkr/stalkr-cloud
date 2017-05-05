//
//  User.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/4/17.
//
//

import JWT
import Vapor
import Fluent
import Foundation

class User: Model {
    
    var id: Node?
    var username: String
    var password: String
    var token: String?
    
    
    init(name: String, password: String) {
        self.username = name
        self.password = password
    }
    
    required init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        username = try node.extract("username")
        password = try node.extract("password")
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "password": password
            ])
    }
    
    func createToken() throws -> String {
        let payload = Node([SubjectClaim("\(username)")])
        let jwt = try JWT(payload: payload, signer: HS256(key: "jwtkey".makeBytes()))
        
        let token = try jwt.createToken()
        self.token = token
        return token
    }
}

// Preparations

extension User: Preparation {
    
    static func prepare(_ database: Database) throws {
        
        try database.create("users") { users in
            users.id()
            users.string("username")
            users.string("password")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("users")
    }
}
