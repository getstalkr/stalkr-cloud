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
import AuthProvider

class TeamController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("team") {
            let authed = $0.grouped(TokenAuthenticationMiddleware(User.self))

            authed.post("create", handler: create)
        }
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        
        let name = try request.assertHeaderValue(forKey: "name")
        
        try Team.assertNoFirst(with: (Team.Properties.name, name))
        
        let team = Team(name: name)
        try team.save()
        
        return team
    }
}
