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
import AuthProvider

class UserController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("user") {
            $0.post("register", handler: register)
            $0.post("login", handler: login)
            
            let authed = $0.grouped([TokenAuthenticationMiddleware(User.self)])
            
            authed.get("me", handler: me)
        }
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        let auth = try request.assertBasicAuth()
        
        let user = User(name: auth.username,
                        password: try auth.password.hashed(by: drop))
        
        try user.save()
        
        return user
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        
        let auth = try request.assertBasicAuth()
        
        let hashedAuth = Password(username: auth.username,
                                  password: try auth.password.hashed(by: drop))
        
        let user = try User.authenticate(hashedAuth)
        
        let token = try UserToken.generate(for: user)
        
        try token.save()
        
        return token.token
    }
    
    func me(request: Request) throws -> ResponseRepresentable {
        
        return try request.user()
    }
}
