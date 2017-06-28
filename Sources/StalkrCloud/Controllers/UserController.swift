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
            authed.get("shorttoken", handler: shortToken)
        }
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        let auth = try request.assertBasicAuth()
        
        try User.assertNoFirst(with: (User.Keys.username,
                                      auth.username))
        
        let user = User(name: auth.username,
                        password: try auth.password.hashed(by: drop))
        
        try user.save()
        
        return user
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        let auth = try request.assertBasicAuth()
        
        let hashedPassword = try auth.password.hashed(by: drop)
        
        let hashedAuth = Password(username: auth.username,
                                  password: hashedPassword)
        
        let user = try User.authenticate(hashedAuth)
        
        let token = try UserToken.generate(for: user)
        
        try token.save()
        
        return token
    }
    
    func me(request: Request) throws -> ResponseRepresentable {
        return try request.user()
    }
    
    func shortToken(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        user.shortToken = try User.ShortToken.makeUnique()
        
        try user.save()
        
        return user.shortToken!
    }
}
