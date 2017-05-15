//
//  TeamController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/5/17.
//
//

import HTTP
import Vapor
import Foundation

class TeamController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("team") { team in
            
            team.group(AuthMiddleware.user) { authTeam in
                authTeam.post("create", handler: create)
            }
            
            team.get("memberships", handler: memberships)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        
        guard let name = request.headers["name"]?.string else {
            throw Abort(Status.badRequest, metadata: "Missing name")
        }
        
        let team = Team(name: name)
        try team.save()
        
        return JSON(["success": true])
    }
    
    func memberships(request: Request) throws -> ResponseRepresentable {
        
        guard let teamid = request.headers["teamid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "Missing teamid")
        }
        
        let memberships = try TeamMembership.all(with: [("teamid", teamid)])
        
        return try JSON(node: memberships)
    }
}
