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
    case noParameter(String)
    case parameterNotOfType(String, type: String)
    
    public var status: Status {
        switch self {
        case .noValueForHeaderKey(_):
            return .badRequest
        case .noBasicAuth:
            return .unauthorized
        case .noBearerAuth:
            return .unauthorized
        case .noParameter(_):
            return .notFound
        case .parameterNotOfType(_, _):
            return .badRequest
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
        case .noParameter(_):
            return "noParameter"
        case .parameterNotOfType(_, _):
            return "parameterNotOfType"
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
        case .noParameter(let p):
            return "missing route parameter :\(p)"
        case .parameterNotOfType(let p, let type):
            return "route parameter :\(p) not of type \(type)"
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
    
    func assertHeaderValue(
        forKey key: String
        ) throws -> String {
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
    
    fileprivate func _assertParameter(
        _ p: String
        ) throws -> Parameters {
        if let _p = self.parameters[p] {
            return _p
        }
        
        throw RequestAssertError.noParameter(p)
    }
    
    func assertParameter(
        _ p: String
        ) throws -> Parameters {
        return try _assertParameter(p)
    }
    
    func assertParameter(
        _ p: String
        ) throws -> Int {
        let _p = try _assertParameter(p)
        if let v = _p.int {
            return v
        }
        throw RequestAssertError.parameterNotOfType(p, type: "Int")
    }
    
    func assertParameter(
        _ p: String
        ) throws -> String {
        let _p = try _assertParameter(p)
        if let v = _p.string {
            return v
        }
        throw RequestAssertError.parameterNotOfType(p, type: "String")
    }
}
