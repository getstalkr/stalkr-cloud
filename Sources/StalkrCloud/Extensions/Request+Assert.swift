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
    case noHeaderValueForKey(String)
    case noBasicAuth
    case noBearerAuth
    case noParameter(String)
    case parameterNotOfType(String, type: String)
    case noJSON
    case noJSONValueForKey(String)
    case JSONValueNotOfType(String, type: String)

    public var status: Status {
        switch self {
        case .noHeaderValueForKey(_):
            return .badRequest
        case .noBasicAuth:
            return .unauthorized
        case .noBearerAuth:
            return .unauthorized
        case .noParameter(_):
            return .notFound
        case .parameterNotOfType(_, _):
            return .badRequest
        case .noJSON:
            return .badRequest
        case .noJSONValueForKey(_):
            return .badRequest
        case .JSONValueNotOfType(_, _):
            return .badRequest
        }
    }
}

extension RequestAssertError: Debuggable {
    public var identifier: String {
        switch self {
        case .noHeaderValueForKey(_):
            return "noHeaderValueForKey"
        case .noBasicAuth:
            return "noBasicAuth"
        case .noBearerAuth:
            return "noBearerAuth"
        case .noParameter(_):
            return "noParameter"
        case .parameterNotOfType(_, _):
            return "parameterNotOfType"
        case .noJSON:
            return "noJSON"
        case .noJSONValueForKey(_):
            return "noJSONValueForKey"
        case .JSONValueNotOfType(_, _):
            return "JSONValueNotOfType"
        }
    }

    public var reason: String {
        switch self {
        case .noHeaderValueForKey(let key):
            return "no header value for key \(key)"
        case .noBasicAuth:
            return "missing basic authentication header"
        case .noBearerAuth:
            return "missing bearer authentication header"
        case .noParameter(let p):
            return "missing route parameter :\(p)"
        case .parameterNotOfType(let p, let type):
            return "route parameter :\(p) not of type \(type)"
        case .noJSON:
            return "no JSON or invalid"
        case .noJSONValueForKey(let key):
            return "no JSON value for key \(key)"
        case .JSONValueNotOfType(let v, let type):
            return "json value \(v) not of type \(type)"
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

        throw RequestAssertError.noHeaderValueForKey(key)
    }

    func assertJSON() throws -> JSON {
        if let json = self.json {
            return json
        }
        
        throw RequestAssertError.noJSON
    }

    fileprivate func _assertJSONValue(forKey key: String) throws -> JSON {
        if let json = try self.assertJSON()[key] {
            return json
        }

        throw RequestAssertError.noJSONValueForKey(key)
    }

    func assertJSONValue(forKey key: String) throws -> JSON {
        return try _assertJSONValue(forKey: key)
    }

    func assertJSONValue(forKey key: String) throws -> String {
        let _json = try _assertJSONValue(forKey: key)
        if let string = _json.string {
            return string
        }

        throw RequestAssertError.JSONValueNotOfType(key, type: "String")
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
