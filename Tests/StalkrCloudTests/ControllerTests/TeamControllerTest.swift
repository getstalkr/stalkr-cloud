//
//  TeamControllerTests.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/15/17.
//
//

import XCTest

@testable import StalkrCloud

import Foundation
import Crypto
import Vapor

class TeamControllerTest: ControllerTest {
    
    static var allTests = [
        ("testTeamCreate", testTeamCreate),
        ("testTeamCreateWithoutAccessToken", testTeamCreateWithoutAccessToken)
    ]
    
    func testTeamCreate() throws {
        let prefix = "testTeamCreate_"
        
        let name = prefix + "name"
        
        let user = UserBuilder.build {
            $0.username = prefix + "username"
            $0.password = prefix + "password"
        }
        
        try user.save()
        
        let role = try Role.withName("user")
        try RoleAssignmentBuilder.build {
            $0.roleId = role?.id
            $0.userId = user.id
        }?.save()
        
        let req = Request(method: .post, uri: "/team/create/")
        
        req.auth.authenticate(user)
        req.headers["name"] = name

        _ = try drop.respond(to: req)
        
        let team = try Team.first(with: [("name", name)])
        
        XCTAssertNotNil(team, "team not created")
    }
    
    func testTeamCreateWithoutAccessToken() throws {
        
        let name = "testTeamCreateWithoutAccessToken_name"
        
        let req = Request(method: .post, uri: "/team/create/")
        req.headers["name"] = name
        
        _ = try drop.respond(to: req)
        
        let team = try Team.first(with: [("name", name)])
        
        XCTAssertNil(team, "team created without access token")
    }
}
