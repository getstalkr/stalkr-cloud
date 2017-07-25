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
import Fluent
import FluentExtended
import AuthProvider

extension UserController: ResourceRepresentable {
    /// [GET] @ /users
    /// Returns all users, optionally filtered by the request data.
    func index(_ req: Request) throws -> ResponseRepresentable {
        if let filterString = req.query?["filter"]?.string {
            let filterJSON = try JSON(bytes: filterString.data(using: .utf8)?.makeBytes() ?? [])
            let filter = try Filter(node: Node(filterJSON))
            return try User.makeQuery().filter(filter).all().makeJSON()
        }
        
        return try User.all().makeJSON()
    }
    
    /// [GET] @ /users/:id
    /// Returns the user with the ID supplied in the path
    func show(_ req: Request, _ user: User) throws -> ResponseRepresentable {
        return user
    }
    
    /// [POST] @ /users
    /// Creates a new user from the request's Basic Authorization Header.
    /// -------------------------------------------------------------------
    /// Headers: Basic Authorization
    func store(_ req: Request) throws -> ResponseRepresentable {
        let basic = try req.assertBasicAuth()
        let username = basic.username
        let password = try basic.password.hashed(by: drop)
        
        try User.assertNoFirst(with: ("username", .equals, username))
        
        let newUser = User(name: username, password: password)
        
        try newUser.save()
        
        return newUser
    }
    
    /// [DELETE] @ /users
    func clear(_ req: Request) throws -> ResponseRepresentable {
        let token = try req.assertBearerAuth()
        let user = try User.authenticate(token)
        try user.assertRoles(.admin)

        let query = try User.makeQuery()
        query.action = .delete

        if let filterString = req.query?["filter"]?.string {
            let filterJSON = try JSON(bytes: filterString.data(using: .utf8)?.makeBytes() ?? [])
            try query.filter(try Filter(node: Node(filterJSON)))
        }

        try query.raw()
        return Response(status: .ok)
    }
    
    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: store,
            show: show,
            clear: clear
        )
    }
}

final class UserController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        
        drop.resource("users", self)
        
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
