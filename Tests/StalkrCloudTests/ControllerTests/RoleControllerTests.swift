//
//  RoleControllerTests.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/25/17.
//
//

import XCTest

@testable import StalkrCloud

import Foundation
import Vapor

class RoleControllerTests: ControllerTest {
    
    func testRoleAll() throws {
        let prefix = "testRoleAll"
        
        let roles = (0...3).map { i in
            RoleBuilder.build { u in
                u.name = "\(prefix)_role_\(i)"
            }
        }
        try roles.forEach { try $0.save() }
        
        let req = Request(method: .get, uri: "/role/all/")
        
        let res = try drop.respond(to: req)
        
        XCTAssert(try res.body.bytes! == Role.all().makeJSON().makeResponse().body.bytes!)
    }
}
