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
    
    func assertBasicAuth() throws -> Password {
        if let auth = auth.header?.basic {
            return auth
        }
        
        throw Abort(Status.badRequest, metadata: "missing basic authorization header".makeNode(in: nil))
    }
    
    func assertBearerAuth() throws -> Token {
        if let auth = auth.header?.bearer {
            return auth
        }
        
        throw Abort(Status.badRequest, metadata: "missing bearer token".makeNode(in: nil))
    }
}
