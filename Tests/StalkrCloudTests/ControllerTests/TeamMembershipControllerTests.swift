//
//  TeamMembershipControllerTests.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/18/17.
//
//

import XCTest

@testable import StalkrCloud

import Foundation
import Vapor

class TeamMembershipControllerTest: XCTestCase {
    
    private var drop: Droplet!
    
    override func setUp() {
        drop = Droplet.test
    }
    
    func testTeamMembershipCreate() throws {
        let prefix = "testTeamMembershipCreate_"
        
        let user = UserBuilder.build {
            $0.username = prefix + "username"
            $0.password = prefix + "password"
        }
        
        try user.save()
        
        let role = try Role.withName("user")
        try RoleAssignmentBuilder.build {
            $0.roleid = role?.id
            $0.userid = user.id
        }?.save()
        
        let team = TeamBuilder.build { $0.name = prefix + "name" }
        try team.save()
        
        let token = try user.createToken()
        
        
        guard let  userid = user.id,
              let _userid = userid.uint
        else {
            XCTFail("could not retrieve userid")
            return
        }
        
        guard let teamid  = team.id,
              let _teamid = teamid.uint
        else {
            XCTFail("could not retrieve teamid")
            return
        }
        
        let req = Request(method: .post, uri: "/teammembership/create/")
        req.headers["userid"] = _userid.description
        req.headers["teamid"] = _teamid.description
        req.headers["token"] = token
        
        _ = try drop.respond(to: req)
        
        let membership = try TeamMembership.first(with: [("teamid", teamid), ("userid", userid)])
        
        XCTAssertNotNil(membership, "membership not created")
    }
}
