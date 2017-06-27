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
            
        let assignments = try RoleAssignment.all(with: [("userid", user.id)])
            
        return try assignments.makeJSON()
    }
    
    func role(request: Request) throws -> ResponseRepresentable {
        let id = try request.assertHeaderValue(forKey: "id")
        let role = try Role.assertFind(id)
        
        let assignments = try RoleAssignment.all(with: [("roleid", role.id)])
        
        return try assignments.makeJSON()
    }
    
    func create(request: Request) throws -> ResponseRepresentable {
        let userid = try request.assertHeaderValue(forKey: "userid")
        let user = try User.assertFind(userid)
        let roleid = try request.assertHeaderValue(forKey: "roleid")
        let role = try Role.assertFind(roleid)
        
        let assignment = RoleAssignmentBuilder.build {
            $0.roleid = role.id
            $0.userid = user.id
        }
        
        try assignment?.save()
        
        return JSON(["success": true])
    }
}
