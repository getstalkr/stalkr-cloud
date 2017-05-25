//
//  UserController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/4/17.
//
//

import HTTP
import Vapor
import Foundation
import MoreFluent

class UserController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("user") { user in
            user.post("register", handler: register)
            user.post("login", handler: login)
        }
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        let username = try request.value(for: "username")
        let password = try request.value(for: "password")
        
        let user = User(name: username, password: password)
        
        try user.save()
        
        return try JSON(node: ["success": true, "token": try user.createToken()])
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        
        let username = try request.value(for: "username")
        let password = try request.value(for: "password")

        guard let user = try User.first(with: [("username", username),
                                               ("password", password)]) else {
            return try JSON(node: ["success": false, "error": "wrong username or password"])
        }
        
        let token = try user.createToken()
        
        return try JSON(node: ["success": true, "token": token])
    }
}
