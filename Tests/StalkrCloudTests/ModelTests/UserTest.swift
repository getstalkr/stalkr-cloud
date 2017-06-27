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
        ("testThatUserAssignsRole", testThatUserAssignsRole)
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
        
        let prefix = "testThatUserJoinsTeam"
        
        let team = TeamBuilder.build {
            $0.name = "\(prefix)_team_name"
        }
        try team.save()
        
        let user = UserBuilder().build {
            $0.username = "\(prefix)_user_username"
        }
        
        try user.save()
        
        try TeamMembershipBuilder.build {
            $0.teamId = team.id
            $0.userId = user.id
        }?.save()
        
        let membership = try user.teamMemberships.first()
        
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
            $0.roleId = role.id
            $0.userId = user.id
        }?.save()
        
        let assignment = try RoleAssignment.first(with: (RoleAssignment.Keys.userId, user.id),
                                                        (RoleAssignment.Keys.roleId, role.id))
        
        XCTAssertNotNil(assignment, "role_assignment not saved")
    }
}
