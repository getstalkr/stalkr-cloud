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

final class UserController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        let route = drop.grouped("user")
        
        let authed = route.grouped(
            [TokenAuthenticationMiddleware(User.self)]
        )
    
        route.post("register", handler: register)
        route.post("login", handler: login)
        route.post("shorttoken", "login", handler: shortTokenLogin)
            
        authed.get("me", handler: me)
        authed.get("shorttoken", handler: shortToken)
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        let auth = try request.assertBasicAuth()
        
        try User.assertNoFirst(with: ("username", .equals, auth.username))
        
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
    
    func shortTokenLogin(request: Request) throws -> ResponseRepresentable {
        let secret = try request.assertHeaderValue(forKey: "secret")
        
        let user = try User.assertFirst(with:
            ("short_token_secret", .equals, secret),
            ("short_token_expiration", .greaterThan, Date()))
        
        let token = try UserToken.generate(for: user)
        
        try token.save()
        
        return token
    }
    
    func me(request: Request) throws -> ResponseRepresentable {
        return try request.user()
    }
    
    func shortToken(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        user.shortToken = try User.makeUniqueShortToken()
        
        try user.save()
        
        return user.shortToken
    }
}
