//
//  RoleAssignmentController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/25/17.
//
//

import HTTP
import Vapor
import Foundation
import MoreFluent

class RoleAssignmentController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("roleassignment") {
            $0.get("all", handler: all)
            $0.get("role", handler: role)
            $0.get("user", handler: user)
            
            $0.group(AuthMiddleware.admin) {
                $0.post("create", handler: create)
            }
        }
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        return try RoleAssignment.all().makeJSON()
    }
    
    func user(request: Request) throws -> ResponseRepresentable {
        let user = try User.findOrThrow(request.value(for: "id"))
            
        let assignments = try RoleAssignment.all(with: [("userid", user.id)])
            
        return try assignments.makeJSON()
    }
    
    func role(request: Request) throws -> ResponseRepresentable {
        let role = try Role.findOrThrow(request.value(for: "id"))
        
        let assignments = try RoleAssignment.all(with: [("roleid", role.id)])
        
        return try assignments.makeJSON()
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let user = try User.findOrThrow(request.value(for: "userid"))
        let role = try Role.findOrThrow(request.value(for: "roleid"))
        
        let assignment = RoleAssignmentBuilder.build {
            $0.roleid = role.id
            $0.userid = user.id
        }
        
        try assignment?.save()
        
        return JSON(["success": true])
    }
}
