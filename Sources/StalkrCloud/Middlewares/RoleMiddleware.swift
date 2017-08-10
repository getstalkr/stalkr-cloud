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

protocol RolesMiddleware: Middleware {
    associatedtype RolesType: Roles

    var roles: RolesType { get set }

    func roles(for: Request) -> RolesType

    init(roles: RolesType)
}

extension RolesMiddleware {
    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        let roles = self.roles(for: request)

        if !self.roles.isSubset(of: roles) {
            throw Abort(Status.unauthorized, metadata: "unauthorized")
        }

        return try next.respond(to: request)
    }
}
