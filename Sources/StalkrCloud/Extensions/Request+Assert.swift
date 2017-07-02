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
    case noBody
}

extension RequestAssertError: Debuggable {
    public var identifier: String {
        switch self {
        case .noValueForHeaderKey(_):
            return "noValueForHeaderKey"
        case .noBody:
            return "noBody"
        }
    }
    
    public var reason: String {
        switch self {
        case .noValueForHeaderKey(let key):
            return "no value found for header key \(key)"
        case .noBody:
            return "body not found"
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
}
