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
    
    func roles(request: Request) throws -> ResponseRepresentable {
        return try Role.all().makeJSON()
    }
    
    func assignments(request: Request) throws -> ResponseRepresentable {
        if let userid = request.data["userid"]?.uint {
            guard let _ = try User.find(userid) else {
                throw Abort(Status.badRequest, metadata: "invalid userid")
            }
            
            let assignments = try RoleAssignment.makeQuery().filter("userid", userid).all()
            
            return try assignments.makeJSON()
        }

        return try RoleAssignment.all().makeJSON()
    }
    
    func assign(request: Request) throws -> ResponseRepresentable {
        guard let roleid = request.data["roleid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "Missing roleid")
        }
        
        guard let userid = request.data["userid"]?.uint else {
            throw Abort(Status.badRequest, metadata: "Missing userid")
        }
        
        guard let role = try Role.makeQuery().filter("id", roleid).first() else {
            throw Abort(Status.badRequest, metadata: "Role does not exist")
        }
        
        guard let user = try User.makeQuery().filter("id", userid).first() else {
            throw Abort(Status.badRequest, metadata: "User does not exist")
        }
        
        if try RoleAssignment.makeQuery().filter("roleid", roleid).filter("userid", userid).first() != nil {
            throw Abort(Status.badRequest, metadata: "This Role Assignment is already in place")
        }
        
        guard try user.assign(role: role) else {
            throw Abort(Status.badRequest, metadata: "Could not assign role")
        }
        
        return JSON(["success": true])
    }
}
