//
//  SmartTokenController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 6/21/17.
//
//

import HTTP
import Vapor
import Foundation
import MoreFluent
import AuthProvider

class SmartTokenController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("smarttoken") {
            let authed = $0.grouped(TokenAuthenticationMiddleware(User.self))
            
            authed.get("generate", handler: generate)
        }
    }
    
    func generate(request: Request) throws -> ResponseRepresentable {
        let user = try request.user()
        let token = try SmartToken.generate(for: user)
        
        try token.save()
        
        return token
    }
}
