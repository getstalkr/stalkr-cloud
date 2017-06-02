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
    
    static var allTests = [
        ("testThatUserExists", testThatUserExists),
        ("testThatUserJoinsTeam", testThatUserJoinsTeam),
        ("testThatUserAssignsRole", testThatUserAssignsRole),
        ("testThatUserCreatesToken", testThatUserCreatesToken)
    ]
    
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
        
        try TeamMembershipBuilder.build {
            $0.teamid = team.id
            $0.userid = user.id
        }?.save()
        
        let membership = try TeamMembership.first(with: [("userid", user.id)])
        
        XCTAssertNotNil(membership, "team_membership not saved")
    }
    
    func testThatUserAssignsRole() throws {
        
        let role = RoleBuilder().build()
        try role.save()
        
        let user = UserBuilder().build {
            $0.uniqueUsername()
        }
        
        try user.save()
        
        try RoleAssignmentBuilder.build {
            $0.roleid = role.id
            $0.userid = user.id
        }?.save()
        
        let assignment = try RoleAssignment.first(with: [("userid", user.id),
                                                         ("roleid", role.id)])
        
        XCTAssertNotNil(assignment, "role_assignment not saved")
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
