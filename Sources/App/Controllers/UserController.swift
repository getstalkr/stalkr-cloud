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
    
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        if let _ = try User.query().filter("username", username).first() {
            throw Abort.custom(status: Status.badRequest, message: "Username already in use")
        }
        
        var user = User(name: username, password: password)
        
        let token = try user.createToken()
        try user.save()
        
        return try JSON(node: ["success": true, "token": token])
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        
        guard let username = request.data["username"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        guard let password = request.data["password"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing username or password")
        }
        
        guard var user = try User.query().filter("username", username).filter("password", password).first() else {
            throw Abort.custom(status: Status.badRequest, message: "Wrong username or password")
        }
        
        let token = try user.createToken()
        try user.save()
        
        return try JSON(node: ["success": true, "token": token])
    }
    
    func jointeam(request: Request) throws -> ResponseRepresentable {
        
        guard let teamid = request.data["teamid"]?.uint else {
            throw Abort.custom(status: Status.badRequest, message: "Missing teamid")
        }
        
        guard let team = try Team.query().filter("id", teamid).first() else {
            throw Abort.custom(status: Status.badRequest, message: "Team does not exist")
        }
        
        guard let user = request.user, let userid = user.id else {
            throw Abort.custom(status: Status.badRequest, message: "No user")
        }
        
        if try TeamMembership.query().filter("teamid", teamid).filter("userid", userid).first() != nil {
            throw Abort.custom(status: Status.badRequest, message: "This Team Membership already exists")
        }
        
        guard var membership = try user.join(team: team) else {
            throw Abort.custom(status: Status.badRequest, message: "Could not join team")
        }
        
        try membership.save()
        
        return try JSON(node: ["success": true, "membership": membership.makeNode()])
    }
}
