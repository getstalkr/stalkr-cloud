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
    
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        
        guard let token = request.data["token"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "missing token")
        }
        
        guard let user = try User.query().filter("token", token).first() else {
            throw Abort.custom(status: Status.badRequest, message: "invalid token")
        }
        
        request.user = user
        
        return try next.respond(to: request)
    }
}
