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
        drop.group("role") { role in
            
            role.get("roles", handler: roles)
            role.get("assignments", handler: assignments)
            
            let admin = role.grouped(AuthMiddleware.admin)
            admin.get("assign", handler: assign)
        }
    }
    
    func roles(request: Request) throws -> ResponseRepresentable {
        return try Role.all().makeJSON()
    }
    
    func assignments(request: Request) throws -> ResponseRepresentable {
        if let userid = request.headers["userid"]?.uint {
            guard let _ = try User.find(userid) else {
                throw Abort(Status.badRequest, metadata: "invalid userid")
            }
            
            let assignments = try RoleAssignment.all(with: [("userid", userid)])
            
            return try assignments.makeJSON()
        }

        return try RoleAssignment.all().makeJSON()
    }
    
    func assign(request: Request) throws -> ResponseRepresentable {
        guard let user = try User.find(request.value(for: "userid")) else {
            throw Abort(Status.badRequest, metadata: "user not found")
        }
        
        guard let role = try Role.find(request.value(for: "roleid")) else {
            throw Abort(Status.badRequest, metadata: "role not found")
        }
        
        if try RoleAssignment.first(with: [("roleid", role.id),
                                           ("userid", user.id)]) != nil {
            throw Abort(Status.badRequest, metadata: "This Role Assignment is already in place")
        }
        
        let _assignment = RoleAssignmentBuilder.build {
            $0.roleid = role.id
            $0.userid = user.id
        }
        
        guard let assignment = _assignment else {
            throw Abort(Status.badRequest, metadata: "Could not assign role")
        }
        
        try assignment.save()
        
        return JSON(["success": true])
    }
}
