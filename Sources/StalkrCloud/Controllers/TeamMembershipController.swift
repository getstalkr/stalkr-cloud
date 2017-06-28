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
        let userId = try request.assertHeaderValue(forKey: "user_id")
        let user = try User.assertFind(userId)
        let teamId = try request.assertHeaderValue(forKey: "team_id")
        let team = try Team.assertFind(teamId)
        
        try TeamMembership.assertNoFirst(with: (TeamMembership.Keys.userId, .equals, userId),
                                               (TeamMembership.Keys.teamId, .equals, teamId))
        
        let membership = TeamMembershipBuilder.build {
            $0.teamId = team.id!
            $0.userId = user.id!
        }!
        
        try membership.save()
        
        return membership
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        return try TeamMembership.all().makeJSON()
    }
    
    func team(request: Request) throws -> ResponseRepresentable {
        let id = try request.assertHeaderValue(forKey: "id")
        return try TeamMembership.all(with: (TeamMembership.Keys.teamId, .equals, id)).makeJSON()
    }
    
    func user(request: Request) throws -> ResponseRepresentable {
        let id = try request.assertHeaderValue(forKey: "id")
        return try TeamMembership.all(with: (TeamMembership.Keys.userId, .equals, id)).makeJSON()
    }
}
