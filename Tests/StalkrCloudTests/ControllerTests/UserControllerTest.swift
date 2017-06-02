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
import JWT

class UserControllerTests: ControllerTest {
    
    static var allTests = [
        ("testUserRegister", testUserRegister),
        ("testUserLogin", testUserLogin),
        ("testUserLoginError", testUserLoginError)
    ]
    
    func testUserRegister() throws {
        
        let username = "testUserRegister_username"
        let password = "testUserRegister_password"
        
        let req = Request(method: .post, uri: "/user/register/")
        req.headers["username"] = username
        req.headers["password"] = password
        
        _ = try drop.respond(to: req)
        
        let user = try User.first(with: [("username", username)])
        
        XCTAssertNotNil(user, "user not registered")
    }
    
    func testUserLogin() throws {
        let prefix = "testUserLogin"
        let user = UserBuilder.build {
            $0.username = "\(prefix)_username"
            $0.password = "\(prefix)_password"
        }
        try user.save()
        
        let req = Request(method: .post, uri: "/user/login")
        req.headers["username"] = user.username
        req.headers["password"] = user.password
        
        let res = try drop.respond(to: req)

        XCTAssert(res.json?["success"] == true)
    }
    
    func testUserLoginError() throws {
        let prefix = "testUserLoginError"
        let user = UserBuilder.build {
            $0.username = "\(prefix)_username"
            $0.password = "\(prefix)_password"
        }
        try user.save()
        
        let req = Request(method: .post, uri: "/user/login")
        req.headers["username"] = user.username
        req.headers["password"] = "wrong"
        
        let res = try drop.respond(to: req)
        
        XCTAssert(res.json?["success"] == false)
    }
}
