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

class UserControllerTest: XCTestCase {
    
    private var drop: Droplet!
    
    override func setUp() {
        drop = Droplet.test
    }
    
    func testUserRegister() throws {
        
        let username = "testUserRegister_username"
        let password = "testUserRegister_password"
        
        let req = Request(method: .post, uri: "/user/register/")
        req.headers["username"] = username
        req.headers["password"] = password
        
        _ = try drop.respond(to: req)
        
        let user = try User.makeQuery().filter("username", username).first()
        
        XCTAssertNotNil(user, "user not registered")
    }
    
    func testUserRegisterWithoutPassword() throws {
        
        let username = "testUserRegisterWithoutPassword_username"
        
        let req = Request(method: .post, uri: "/user/register/")
        req.headers["username"] = username
        
        _ = try drop.respond(to: req)
        
        let user = try User.makeQuery().filter("username", username).first()
        
        XCTAssertNil(user, "user registered")
    }
    
    func testUserRegisterWithoutUsername() throws {
        
        let password = "testUserRegisterWithoutPassword_password"
        
        let req = Request(method: .post, uri: "/user/register/")
        req.headers["password"] = password
        
        _ = try drop.respond(to: req)
        
        let user = try User.makeQuery().filter("username", "").first()
        
        XCTAssertNil(user, "user registered")
    }
    
    func testUserRegisterWithRepeatedUsername() throws {
            
        let username = "testUserRegister_username"
        let password = "testUserRegister_password"
        
        let req = Request(method: .post, uri: "/user/register/")
        req.headers["username"] = username
        req.headers["password"] = password
        
        _ = try drop.respond(to: req)
        _ = try drop.respond(to: req)
        
        let users = try User.makeQuery().filter("username", username)
        
        XCTAssert(try users.count() == 1, "user registered")
    }
}
