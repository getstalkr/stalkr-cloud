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

enum RequestAssertError: Error {
    case noValueForHeaderKey(String)
    case noValueForJSONKey(String)
    case noIntValueForJSONKey(String)
    case noBody
    case noJSON
}

extension RequestAssertError: Debuggable {
    public var identifier: String {
        switch self {
        case .noValueForHeaderKey(_):
            return "noValueForHeaderKey"
        case .noValueForJSONKey(_):
            return "noValueForJSONKey"
        case .noIntValueForJSONKey(_):
            return "noIntValueForJSONKey"
        case .noBody:
            return "noBody"
        case .noJSON(_):
            return "noJSON"
        }
    }
    
    public var reason: String {
        switch self {
        case .noValueForHeaderKey(let key):
            return "no value found for key \(key) in header"
        case .noValueForJSONKey(let key):
            return "no value found for key \(key) in JSON"
        case .noIntValueForJSONKey(let key):
            return "no int value found for key \(key) in JSON"
        case .noBody:
            return "body not found"
        case .noJSON:
            return "json not found"
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
    
    func assertBody() throws -> String {
        if let value = self.body.bytes?.makeString() {
            return value
        }
        
        throw RequestAssertError.noBody
    }
    
    func assertJSON() throws -> JSON {
        if let value = self.json {
            return value
        }
        
        throw RequestAssertError.noJSON
    }
    
    func assertJSONValue(forKey key: String) throws -> JSON {
        if let value = try self.assertJSON()[key] {
            return value
        }
        
        throw RequestAssertError.noValueForJSONKey(key)
    }
    
    func assertJSONIntValue(forKey key: String) throws -> Int {
        if let value = try self.assertJSONValue(forKey: key).int {
            return value
        }
        
        throw RequestAssertError.noIntValueForJSONKey(key)
    }
}
