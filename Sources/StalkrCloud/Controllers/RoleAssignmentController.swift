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
import AuthProvider

class RoleAssignmentController {
    
    let drop: Droplet
    
    init(drop: Droplet) {
        self.drop = drop
    }
    
    func addRoutes() {
        drop.group("roleassignment") {
            let authed = $0.grouped(TokenAuthenticationMiddleware(User.self))
            
            $0.get("all", handler: all)
            $0.get("role", handler: role)
            $0.get("user", handler: user)
            
            authed.group(RoleMiddleware.admin) {
                $0.post("create", handler: create)
            }
        }
    }
    
    func all(request: Request) throws -> ResponseRepresentable {
        return try RoleAssignment.all().makeJSON()
    }
    
    func user(request: Request) throws -> ResponseRepresentable {
        let id = try request.assertHeaderValue(forKey: "id")
        let user = try User.assertFind(id)
            
        let assignments = try RoleAssignment.all(with: (RoleAssignment.Keys.userId, .equals, user.id))
            
        return try assignments.makeJSON()
    }
    
    func role(request: Request) throws -> ResponseRepresentable {
        let id = try request.assertHeaderValue(forKey: "id")
        let role = try Role.assertFind(id)
        
        let assignments = try RoleAssignment.all(with: (RoleAssignment.Keys.roleId, .equals, role.id))
        
        return try assignments.makeJSON()
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let userid = try request.assertHeaderValue(forKey: "user_id")
        let user = try User.assertFind(userid)
        let roleid = try request.assertHeaderValue(forKey: "role_id")
        let role = try Role.assertFind(roleid)
        
        let assignment = RoleAssignmentBuilder.build {
            $0.roleId = role.id
            $0.userId = user.id
        }!
        
        try assignment.save()
        
        return assignment
    }
}
