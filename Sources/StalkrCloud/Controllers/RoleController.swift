//
//  RoleController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/9/17.
//
//

import HTTP
import Vapor
import Foundation

class RoleController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("role") {
            $0.get("all", handler: all)
        }
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        return try Role.all().makeJSON()
    }
}
