//
//  AuthMiddleware.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/6/17.
//
//

import JWT
import HTTP
import Vapor
import Fluent
import Foundation

class RoleMiddleware: Middleware {
    
    static var admin: RoleMiddleware = RoleMiddleware(roleNames: ["admin"])
    static var user: RoleMiddleware = RoleMiddleware(roleNames: ["user"])
    
    let roleNames: Set<String>
    
    init(roleNames: Set<String>) {
        self.roleNames = roleNames
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        let user = try request.user()
        
        let assignments = try user.roleAssignments.all()
        
        guard roleNames.isSubset(of: try assignments.map { try $0.role.get()! }.map { $0.name }) else {
            throw Abort(Status.unauthorized, metadata: "unauthorized")
        }
        
        return try next.respond(to: request)
    }
}
