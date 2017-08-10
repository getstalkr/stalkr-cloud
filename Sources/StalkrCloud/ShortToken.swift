//
//  ShortToken.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 7/8/17.
//
//

import Foundation
import Vapor
import Fluent

struct ShortToken {
    static let length = 6
    static let lifeTime = 600.0

    static func makeSecret() -> String {
        return String.random(length: length, options: [.uppercase, .numbers])
    }

    static func makeExpiration() -> Date {
        return Date() + ShortToken.lifeTime
    }

    var secret: String? = ShortToken.makeSecret()
    var expiration: Date? = ShortToken.makeExpiration()
}

extension ShortToken: JSONConvertible {
    init(json: JSON) throws {
        self.secret = try json.get("secret")
        self.expiration = try json.get("expiration")
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("secret", self.secret)
        try json.set("expiration", self.expiration)
        return json
    }
}

extension ShortToken: ResponseRepresentable { }
