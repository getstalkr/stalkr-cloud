//
//  UserTests.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/10/17.
//
//

@testable import StalkrCloud

import XCTest

import Vapor
import FluentProvider
import JWT

class UserTest: XCTestCase {
    
    private var drop: Droplet!
    
    override func setUp() {
        drop = Droplet.test
    }
    
    func testThatUserExists() throws {
        
        let user = UserBuilder().build {
            $0.uniqueUsername()
        }
        
        try user.save()
        
        XCTAssert(user.exists, "user not saved")
    }
    
    func testThatUserJoinsTeam() throws {
        
        let team = TeamBuilder().build()
        try team.save()
        
        let user = UserBuilder().build {
            $0.uniqueUsername()
        }
        
        try user.save()
        
        _ = try user.join(team: team)
        
        XCTAssertNotNil(try user.memberships().count == 1, "team_membership not saved")
    }
    
    func testThatUserAssignsRole() throws {
        
        let role = RoleBuilder().build()
        try role.save()
        
        let user = UserBuilder().build {
            $0.uniqueUsername()
        }
        
        try user.save()
        
        _ = try user.assign(role: role)
        
        XCTAssert(try user.assignments().count == 1, "role_assignment not saved")
    }
    
    func testThatUserCreatesToken() throws {
        
        let user = UserBuilder().build {
            $0.uniqueUsername()
        }
        
        try user.save()
        
        let token = try user.createToken()
        
        let queryUser = try User.makeQuery().filter("token", token).first()
        
        XCTAssertEqual(user.id, queryUser?.id, "token not saved")
    }
}
