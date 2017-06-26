//
//  UserControllerTests.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/14/17.
//
//

@testable import StalkrCloud
@testable import Vapor

import XCTest
import HTTP
import FluentProvider
import AuthProvider
import JWT
import Crypto

class UserControllerTest: ControllerTest {
    
    static var allTests = [
        ("testUserRegister", testUserRegister),
        ("testUserLogin", testUserLogin)
    ]
    
    func testUserRegister() throws {
        
        let username = "testUserRegister_username"
        let password = "testUserRegister_password"
        
        let req = Request(method: .post, uri: "/user/register/")
        req.setBasicAuth(username: username, password: password)
        
        _ = try drop.respond(to: req)
        
        let user = try User.first(with: [("username", username)])
        
        XCTAssertNotNil(user, "user not registered")
    }
    
    func testUserLogin() throws {
        let prefix = "testUserLogin"
        
        let username = "\(prefix)_username"
        let password = "\(prefix)_password"
        
        let hashedPassword = try password.hashed(by: drop)
        
        let user = User(name: username, password: hashedPassword)
        try user.save()
        
        let req = Request(method: .post, uri: "/user/login")
        req.setBasicAuth(username: username, password: password)
        
        let res = try drop.respond(to: req)

        XCTAssertNotNil(res.json?["token"])
    }
}
