//
//  Request+Params.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/19/17.
//
//

import Foundation

import HTTP
import FluentProvider
import Foundation
import AuthProvider

enum RequestAssertError: AbortError {
    case noValueForHeaderKey(String)
    case noBasicAuth
    case noBearerAuth
    
    public var status: Status {
        switch self {
        case .noValueForHeaderKey(_):
            return .badRequest
        case .noBasicAuth:
            return .unauthorized
        case .noBearerAuth:
            return .unauthorized
        }
    }
}

extension RequestAssertError: Debuggable {
    public var identifier: String {
        switch self {
        case .noValueForHeaderKey(_):
            return "noValueForHeaderKey"
        case .noBasicAuth:
            return "noBasicAuth"
        case .noBearerAuth:
            return "noBearerAuth"
        }
    }
    
    public var reason: String {
        switch self {
        case .noValueForHeaderKey(let key):
            return "no value found for header key \(key)"
        case .noBasicAuth:
            return "missing basic authentication header"
        case .noBearerAuth:
            return "missing bearer authentication header"
        }
    }
    
    public var possibleCauses: [String] {
        return [
            "malformed request",
            "outdated client"
        ]
    }
    
    public var suggestedFixes: [String] {
        return [
            "make sure the request is valid",
            "update your client"
        ]
    }
}

extension Request {
    
    func assertHeaderValue(forKey key: String) throws -> String {
        if let value = self.headers[HeaderKey(key)] {
            return value
        }
        
        throw RequestAssertError.noValueForHeaderKey(key)
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
