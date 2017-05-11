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

class UserController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("user") { user in
            
            user.post("register", handler: register)
            user.post("login", handler: login)
            
            user.group(AuthMiddleware.user) { authUser in
                authUser.post("jointeam", handler: jointeam)
            }
        }
    }
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string else {
            throw Abort(Status.badRequest, metadata: "Missing username or password")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort(Status.badRequest, metadata: "Missing username or password")
        }
        
        if let _ = try User.makeQuery().filter("username", username).first() {
            throw Abort(Status.badRequest, metadata: "Username already in use")
        }
        
        try User(name: username, password: password).save()
        
        if let token = try User.withName(username)?.createToken() {
            return try JSON(node: ["success": true, "token": token])
        } else {
            return try JSON(node: ["success": true, "token": "could not create token"])
        }
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string else {
            throw Abort(Status.badRequest, metadata: "Missing username or password")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort(Status.badRequest, metadata: "Missing username or password")
        }
        
        guard let user = try User.makeQuery().filter("username", username).filter("password", password).first() else {
            throw Abort(Status.badRequest, metadata: "Wrong username or password")
        }
        
        let token = try user.createToken()
        
        return try JSON(node: ["success": true, "token": token])
    }
    
    func jointeam(request: Request) throws -> ResponseRepresentable {
        
        guard let teamid = request.data["teamid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "Missing teamid")
        }
        
        guard let team = try Team.makeQuery().filter("id", teamid).first() else {
            throw Abort(Status.badRequest, metadata: "Team does not exist")
        }
        
        guard let user = request.user, let userid = user.id else {
            throw Abort(Status.badRequest, metadata: "No user")
        }
        
        if try TeamMembership.makeQuery().filter("teamid", teamid).filter("userid", userid).first() != nil {
            throw Abort(Status.badRequest, metadata: "This Team Membership already exists")
        }
        
        guard try user.join(team: team) else {
            throw Abort(Status.badRequest, metadata: "Could not join team")
        }
        
        return JSON(["success": true])
    }
}
