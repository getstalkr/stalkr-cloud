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
            
            role.group(AuthMiddleware.admin) { authAdmin in
                authAdmin.post("assign", handler: assign)
            }
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
            
            let assignments = try RoleAssignment.makeQuery().filter("userid", userid).all()
            
            return try assignments.makeJSON()
        }

        return try RoleAssignment.all().makeJSON()
    }
    
    func assign(request: Request) throws -> ResponseRepresentable {
        guard let _roleid = request.headers["roleid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "Missing roleid")
        }
        
        guard let role = try Role.find(_roleid),
              let roleid = role.id else {
            throw Abort(Status.badRequest, metadata: "Role does not exist")
        }
        
        guard let _userid = request.headers["userid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "Missing userid")
        }
        
        guard let user = try User.find(_userid),
              let userid = user.id else {
            throw Abort(Status.badRequest, metadata: "User does not exist")
        }
        
        if try RoleAssignment.first(with: [("roleid", roleid),
                                           ("userid", userid)]) != nil {
            throw Abort(Status.badRequest, metadata: "This Role Assignment is already in place")
        }
        
        let _assignment = RoleAssignmentBuilder.build {
            $0.roleid = roleid
            $0.userid = userid
        }
        
        guard let assignment = _assignment else {
            throw Abort(Status.badRequest, metadata: "Could not assign role")
        }
        
        try assignment.save()
        
        return JSON(["success": true])
    }
}
