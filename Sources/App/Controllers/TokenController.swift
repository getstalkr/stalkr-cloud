//
//  TokenController.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/5/17.
//
//

import JWT
import HTTP
import Vapor
import Foundation

import Turnstile
import TurnstileWeb
import TurnstileCrypto

class TokenController {
    func generate(request: Request) throws -> ResponseRepresentable {
        guard let name = request.data["user"]?.string else {
            throw Abort.custom(status: Status.badRequest, message: "Missing user parameter")
        }

        guard let user = try User.query().filter("name", name).first() else {
            throw Abort.custom(status: Status.badRequest, message: "User not found")
        }
        
        let token = try user.createToken()
        return try JSON(node: ["token": token, "decoded_token": JWT(token: token).node])
    }
}
