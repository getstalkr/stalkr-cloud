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

class TeamTest: XCTestCase {
    
    static var allTests = [
        ("testThatTeamExists", testThatTeamExists)
    ]
    
    private var drop: Droplet!
    
    override func setUp() {
        drop = Droplet.test
    }
    
    func testThatTeamExists() throws {
        
        let team = TeamBuilder().build()
        
        try team.save()
        
        XCTAssert(team.exists, "team not saved")
    }
}
