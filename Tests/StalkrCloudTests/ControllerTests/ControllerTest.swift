//
//  ControllerTest.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/26/17.
//
//

import XCTest

@testable import StalkrCloud

import Foundation
import Vapor

class ControllerTest: XCTestCase {
    
    static var drop: Droplet!
    static var admin: User!
    static var user: User!
    
    var drop: Droplet {
        return ControllerTest.drop
    }
    var admin: User {
        return ControllerTest.admin
    }
    var user: User {
        return ControllerTest.user
    }
    
    override static func setUp() {
        drop = drop ?? Droplet.test
        user = user ?? makeTestUser()
        admin = admin ?? makeTestAdmin()
    }

    static func makeTestUser() -> User {
        do {
            let user = UserBuilder.build {
                $0.username = "ControllerTest_User_Username"
                $0.password = "ControllerTest_User_Password"
            }
            try user.save()
            
            let role = try Role.withName("user")
            try RoleAssignmentBuilder.build {
                $0.userid = user.id
                $0.roleid = role?.id
            }?.save()
            
            return user
        }
        catch {
            fatalError("could not instantiate test user")
        }
    }
    
    static func makeTestAdmin() -> User {
        do {
            let user = UserBuilder.build {
                $0.username = "ControllerTest_Admin_Username"
                $0.password = "ControllerTest_Admin_Password"
            }
            try user.save()
            
            let role = try Role.withName("admin")
            try RoleAssignmentBuilder.build {
                $0.userid = user.id
                $0.roleid = role?.id
            }?.save()
            
            return user
        }
        catch {
            fatalError("could not instantiate test admin")
        }
    }
}
