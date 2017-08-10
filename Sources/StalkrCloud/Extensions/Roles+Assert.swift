//
//  Roles+Assert.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 7/18/17.
//
//
import Foundation
import Vapor
import HTTP

enum RolesError: AbortError {
    case unauthorized
}

extension RolesError {
    var status: Status {
        return .unauthorized
    }

    var reason: String {
        return "could not assert roles"
    }
}

extension RolesAssignable {
    func assertRoles(_ roles: RolesType) throws {
        if self.hasRoles(roles) == false {
            throw RolesError.unauthorized
        }
    }
}
