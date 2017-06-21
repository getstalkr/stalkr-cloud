//
//  TeamMembershipController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/16/17.
//
//

import HTTP
import Vapor
import MoreFluent
import Foundation
import AuthProvider

class TeamMembershipController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("teammembership") {
            let authed = $0.grouped(TokenAuthenticationMiddleware(User.self))
            
            authed.post("create", handler: create)
            
            $0.get("all", handler: all)
            $0.get("team", handler: team)
            $0.get("user", handler: user)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let user = try User.findOrThrow(request.value(for: "userid"))
        let team = try Team.findOrThrow(request.value(for: "teamid"))
        
        try TeamMembershipBuilder.build {
            $0.teamid = team.id!
            $0.userid = user.id!
        }?.save()
        
        return JSON(["success": true])
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        return try TeamMembership.all().makeJSON()
    }
    
    func team(request: Request) throws -> ResponseRepresentable {
        let id = try request.value(for: "id")
        return try TeamMembership.all(with: [("teamid", id.makeNode(in: nil))]).makeJSON()
    }
    
    func user(request: Request) throws -> ResponseRepresentable {
        let id = try request.value(for: "id")
        return try TeamMembership.all(with: [("userid", id.makeNode(in: nil))]).makeJSON()
    }
}
