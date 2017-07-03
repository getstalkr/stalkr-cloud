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
            $0.post("shorttoken", "login", handler: shortTokenLogin)
            
            let authed = $0.grouped([TokenAuthenticationMiddleware(User.self)])
            
            authed.get("me", handler: me)
            authed.get("shorttoken", handler: shortToken)
            
            authed.post("dashboard", "new", handler: dashboardNew)
            authed.post("dashboard", "delete", handler: dashboardDelete)
            authed.get("dashboards", handler: dashboards)
        }
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        let auth = try request.assertBasicAuth()
        
        try User.assertNoFirst(with: (User.Keys.username, .equals, auth.username))
        
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
        
        let user = try User.assertFirst(with: (User.Keys.shortTokenSecret, .equals, secret),
                                              (User.Keys.shortTokenExpiration, .greaterThan, Date()))
        
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
    
    func dashboards(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        let dashboards: Siblings<User, Dashboard, DashboardViewership> = user.siblings()
        
        return try "[\(dashboards.all().map { $0.configuration }.joined(separator: ","))]"
    }
    
    func dashboardNew(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        let configuration = try request.assertBody()
        
        let dashboard = Dashboard(name: "dashboard", configuration: configuration)
        
        try dashboard.save()
        
        let viewership = DashboardViewership(dashboardId: dashboard.id!, userId: user.id!)
        
        try viewership.save()
        
        return viewership
    }
    
    func dashboardDelete(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        
        let id = try request.assertJSONIntValue(forKey: "id")
        
        let viewerships = try DashboardViewership.all(with:
            (DashboardViewership.Keys.userId, .equals, user.id!))
        
        let viewership: DashboardViewership? =
            id < viewerships.count ? viewerships[id] : nil
        
        let dashboard = viewership?.dashboard
        try viewership?.delete()
        try dashboard?.delete()
        
        return "{\"success\": true}"
    }
}
