//
//  RoleAssignmentControllerTests.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/26/17.
//
//

import XCTest

@testable import StalkrCloud

import Foundation
import Vapor

class RoleAssignmentControllerTest: ControllerTest {
    
    static var allTests = [
        ("testRoleAssignmentCreate", testRoleAssignmentCreate),
        ("testRoleAssignmentAll", testRoleAssignmentAll),
        ("testRoleAssignmentRole", testRoleAssignmentRole),
        ("testRoleAssignmentUser", testRoleAssignmentUser)
    ]
    
    func testRoleAssignmentCreate() throws {
        let prefix = "testRoleAssignmentCreate"
        
        let user = UserBuilder.build {
            $0.username = "\(prefix)_username"
        }
        try user.save()
        
        let role = try Role.withName("user")
        
        let req = Request(method: .post, uri: "/roleassignment/create/")
        req.headers["roleid"] = role?.id?.string
        req.headers["userid"] = user.id?.string
        req.headers["token"] = try admin.createToken()
        
        _ = try drop.respond(to: req)
        
        let assignment = try RoleAssignment.first(with: [("roleid", role?.id), ("userid", user.id)])
        
        XCTAssertNotNil(assignment, "assignment not created")
    }
    
    func testRoleAssignmentAll() throws {
        let prefix = "testRoleAssignmentAll"
        
        let users = UserBuilder.build(4) { u, i in
                u.username = "\(prefix)_username_\(i)"
            }
        try users.forEach { try $0.save() }
        
        let roles = RoleBuilder.build(4) { r, i in
                r.name = prefix + "\(prefix)_name_\(i)"
            }
        try roles.forEach { try $0.save() }
        
        let assignments = roles.map { r in
            users.map { u in
                RoleAssignmentBuilder.build { b in
                    b.roleid = r.id
                    b.userid = u.id
                }
            }
        }.flatMap {$0}
        
        try assignments.forEach { try $0?.save() }
        
        let req = Request(method: .get, uri: "/roleassignment/all/")
        
        let res = try drop.respond(to: req)
        
        XCTAssert(try res.body.bytes! == RoleAssignment.all().makeJSON().makeResponse().body.bytes!)
    }
    
    func testRoleAssignmentRole() throws {
        let prefix = "testRoleAssignmentRole"
        
        let users = UserBuilder.build(4) { u, i in
            u.username = "\(prefix)_username_\(i)"
        }
        try users.forEach { try $0.save() }
        
        let roles = RoleBuilder.build(4) { r, i in
            r.name = prefix + "\(prefix)_name_\(i)"
        }
        try roles.forEach { try $0.save() }
        
        let assignments = roles.map { r in
            users.map { u in
                RoleAssignmentBuilder.build { b in
                    b.roleid = r.id
                    b.userid = u.id
                }
            }
            }.flatMap {$0}
        
        try assignments.forEach { try $0?.save() }
        
        let role = roles[2]
        
        let req = Request(method: .get, uri: "/roleassignment/role/")
        req.headers["id"] = role.id?.string
        
        let res = try drop.respond(to: req)
        
        XCTAssert(try res.body.bytes! == RoleAssignment.all(with: [("roleid", role.id)]).makeJSON().makeResponse().body.bytes!)
    }
    
    func testRoleAssignmentUser() throws {
        let prefix = "testRoleAssignmentUser"
        
        let users = UserBuilder.build(4) { u, i in
            u.username = "\(prefix)_username_\(i)"
        }
        try users.forEach { try $0.save() }
        
        let roles = RoleBuilder.build(4) { r, i in
            r.name = prefix + "\(prefix)_name_\(i)"
            r.readableName = "readableName"
        }
        try roles.forEach { try $0.save() }
        
        let assignments = roles.map { r in
            users.map { u in
                RoleAssignmentBuilder.build { b in
                    b.roleid = r.id
                    b.userid = u.id
                }
            }
            }.flatMap {$0}
        
        try assignments.forEach { try $0?.save() }
        
        let user = users[2]
        
        let req = Request(method: .get, uri: "/roleassignment/user/")
        req.headers["id"] = user.id?.string
        
        let res = try drop.respond(to: req)
        
        XCTAssert(try res.body.bytes! == RoleAssignment.all(with: [("userid", user.id)]).makeJSON().makeResponse().body.bytes!)
    }
}
