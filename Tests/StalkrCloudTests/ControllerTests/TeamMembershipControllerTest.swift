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

class TeamMembershipControllerTest: ControllerTest {
    
    static var allTests = [
        ("testTeamMembershipCreate", testTeamMembershipCreate),
        ("testTeamMembershipAll", testTeamMembershipAll),
        ("testTeamMembershipTeam", testTeamMembershipTeam),
        ("testTeamMembershipUser", testTeamMembershipUser)
    ]
    
    func testTeamMembershipCreate() throws {
        let prefix = "testTeamMembershipCreate_"
        
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
        
        let team = TeamBuilder.build { $0.name = prefix + "name" }
        try team.save()
        
        
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
        req.headers["user_id"] = _userid.description
        req.headers["team_id"] = _teamid.description
        req.setBearerAuth(token: adminToken.token)
        
        _ = try drop.respond(to: req)
        
        let membership = try TeamMembership.first(with: (TeamMembership.Keys.teamId, teamid),
                                                        (TeamMembership.Keys.userId, userid))
        
        XCTAssertNotNil(membership, "membership not created")
    }
    
    func testTeamMembershipAll() throws {
        let prefix = "testTeamMembershipAll"
        
        let users = (0...3).map { i in
            UserBuilder.build { u in
                u.username = "\(prefix)_username_\(i)"
            }
        }
        try users.forEach { try $0.save() }
        
        let teams = (0...3).map { i in
            TeamBuilder.build { t in
                t.name = prefix + "\(prefix)_name_\(i)"
            }
        }
        try teams.forEach { try $0.save() }
        
        
        
        let memberships = teams.map { t in
            users.map { u in
                TeamMembershipBuilder.build { b in
                    b.teamId = t.id
                    b.userId = u.id
                }
            }
        }.flatMap {$0}
        
        try memberships.forEach { try $0?.save() }
        
        let req = Request(method: .get, uri: "/teammembership/all/")
        
        let res = try drop.respond(to: req)
        
        XCTAssert(try res.body.bytes! == TeamMembership.all().makeJSON().makeResponse().body.bytes!)
    }
    
    func testTeamMembershipTeam() throws {
        let prefix = "testTeamMembershipTeam"
        
        let users = UserBuilder.build(4) {
            $0.username = "\(prefix)_username_\($1)"
        }
        try users.forEach { try $0.save() }
        
        let teams = TeamBuilder.build(4) {
            $0.name = prefix + "\(prefix)_name_\($1)"
        }
        try teams.forEach { try $0.save() }
        
        
        
        let memberships = teams.map { t in
            users.map { u in
                TeamMembershipBuilder.build { b in
                    b.teamId = t.id
                    b.userId = u.id
                }
            }
        }.flatMap {$0}
        
        try memberships.forEach { try $0?.save() }
        
        let team = teams[2]
        
        let req = Request(method: .get, uri: "/teammembership/team/")
        req.headers["id"] = team.id?.string
        
        let res = try drop.respond(to: req)
        
        XCTAssert(try res.body.bytes! == team.teamMemberships.all().makeJSON().makeResponse().body.bytes!)
    }
    
    func testTeamMembershipUser() throws {
        let prefix = "testTeamMembershipUser"
        
        let users = UserBuilder.build(4) {
            $0.username = "\(prefix)_username_\($1)"
        }
        try users.forEach { try $0.save() }
        
        let teams = TeamBuilder.build(4) {
            $0.name = prefix + "\(prefix)_name_\($1)"
        }
        try teams.forEach { try $0.save() }
        
        
        
        let memberships = teams.map { t in
            users.map { u in
                TeamMembershipBuilder.build { b in
                    b.teamId = t.id
                    b.userId = u.id
                }
            }
            }.flatMap {$0}
        
        try memberships.forEach { try $0?.save() }
        
        let user = users[2]
        
        let req = Request(method: .get, uri: "/teammembership/user/")
        req.headers["id"] = user.id?.string
        
        let res = try drop.respond(to: req)
        
        XCTAssert(try res.body.bytes! == user.teamMemberships.all().makeJSON().makeResponse().body.bytes!)
    }
}
