//
//  Auth+Extensions.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 7/17/17.
//
//

import Authentication
import HTTP

extension AuthorizationHeader {
    init(basic: Password) {
        let credentials = "\(basic.username):\(basic.password)"
        let encoded = credentials.makeBytes().base64Encoded.makeString()
        self.init(string: "Basic \(encoded)")
    }
}

extension AuthorizationHeader {
    init(bearer: Token) {
        self.init(string: "Bearer \(bearer.string)")
    }
}

extension Request {
    func setAuthHeader(_ header: AuthorizationHeader) {
        self.headers[.authorization] = header.string
    }
}
