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
    private static var user: User!
    
    private static let username = "testName"
    private static let password = "testPassword"
    
    static override func setUp() {
        do {
            config = try Config()
            try config.setup()

            drop = try Droplet(config)
            
            try User(name: username, password: password).save()
            
            user = try User.makeQuery().filter("username", username)
                .filter("password", password).first()
            
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func testThatUserExists() throws {
        XCTAssertNotNil(UserTest.user, "user not saved in db")
    }
    
    func testThatUserJoinsTeam() throws {
        
        
        let teamName = "testTeamName"
        
        try Team(name: teamName).save()
        
        let teamQuery = try Team.makeQuery().filter("name", teamName)
        
        guard let team = try teamQuery.first() else {
            XCTFail("team not saved in db")
            return
        }
        
        try UserTest.user.join(team: team)
        
        let membershipQuery = try TeamMembership.makeQuery().filter("userid", UserTest.user.id)
                                                            .filter("teamid", team.id)
        
        XCTAssertNotNil(try membershipQuery.first())
    }
}
