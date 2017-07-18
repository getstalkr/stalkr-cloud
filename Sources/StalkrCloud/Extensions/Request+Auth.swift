//
//  Request+Auth.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/6/17.
//
//

import HTTP
import Vapor
import Foundation
import AuthProvider

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated()
    }
}
