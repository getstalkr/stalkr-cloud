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
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        
        let name = try request.value(for: "name")
        
        let team = Team(name: name)
        try team.save()
        
        return JSON(["success": true])
    }
}
