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

class AuthMiddleware: Middleware {
    
    static var admin: AuthMiddleware = AuthMiddleware(roleNames: ["admin"])
    static var user: AuthMiddleware = AuthMiddleware(roleNames: ["user"])
    
    let roleNames: Set<String>
    
    init(roleNames: Set<String>) {
        self.roleNames = roleNames
    }
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        guard let token = request.headers["token"]?.string else {
            throw Abort(Status.badRequest, metadata: "missing token")
        }
        
        guard let user = try User.first(with: [("token", token)]),
              let userid = user.id else {
            throw Abort(Status.badRequest, metadata: "invalid token")
        }
        
        let assignments = try RoleAssignment.all(with: [("userid", userid)])
        
        guard roleNames.isSubset(of: try assignments.map { try $0.role()! }.map { $0.name }) else {
            throw Abort(Status.unauthorized, metadata: "unauthorized")
        }
        
        request.user = user
        
        return try next.respond(to: request)
    }
}
