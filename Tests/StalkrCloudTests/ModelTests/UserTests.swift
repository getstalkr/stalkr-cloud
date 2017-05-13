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
    
    private static var config: Config!
    private static var drop: Droplet!
    
    static override func setUp() {
        do {
            config = try Config()
            try config.setup()

            drop = try Droplet(config)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func testThatUserExists() throws {
        
        let user = UserBuilder().build()
        try user.save()
        
        XCTAssertFalse(user.exists, "user not saved")
    }
    
    func testThatUserJoinsTeam() throws {
        
        let team = TeamBuilder().build()
        try team.save()
        
        let user = UserBuilder().build()
        try user.save()
        
        try user.join(team: team)
        
        let membershipQuery = try TeamMembership.makeQuery().filter("userid", user.id)
                                                            .filter("teamid", team.id)
        
        XCTAssertNotNil(try membershipQuery.first(), "team_membership not created")
    }
}
