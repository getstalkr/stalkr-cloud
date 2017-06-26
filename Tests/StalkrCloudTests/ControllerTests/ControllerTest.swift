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
    static var user: User!
    static var userToken: UserToken!
    static var admin: User!
    static var adminToken: UserToken!
    
    var drop: Droplet {
        return ControllerTest.drop
    }
    
    var user: User {
        return ControllerTest.user
    }
    
    var userToken: UserToken {
        return ControllerTest.userToken
    }
    
    var admin: User {
        return ControllerTest.admin
    }
    
    var adminToken: UserToken {
        return ControllerTest.adminToken
    }
    
    override static func setUp() {
        drop = drop ?? Droplet.test
        user = user ?? makeTestUser()
        userToken = userToken ?? makeTestUserToken()
        admin = admin ?? makeTestAdmin()
        adminToken = adminToken ?? makeTestAdminToken()
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
            fatalError("could not make test user")
        }
    }
    
    static func makeTestUserToken() -> UserToken {
        do {
            let token = try UserToken.generate(for: user)
            try token.save()
            return token
        } catch {
            fatalError("could not make test user token")
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
            fatalError("could not make test admin")
        }
    }
    
    static func makeTestAdminToken() -> UserToken {
        do {
            let token = try UserToken.generate(for: admin)
            try token.save()
            return token
        } catch {
            fatalError("could not make test admin token")
        }
    }
}
