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

extension Request {
    
    func value(for param: String) throws -> String {
        if let value = self.headers[HeaderKey(param)] {
            return value
        }
        
        throw Abort(Status.badRequest, metadata: "request missing header param: \(param)".makeNode(in: nil))
    }
}
