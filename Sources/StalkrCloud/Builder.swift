//
//  Builder.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/12/17.
//
//

import Vapor
import Foundation
import FluentProvider

protocol Builder {
    
    associatedtype T
    
    typealias BuilderClosure = (Self) -> ()
    typealias BuilderClosureN = (Self, UInt) -> ()
    
    init()
    
    static func build(buildClosure: BuilderClosure?) -> T
    func build(buildClosure: BuilderClosure?) -> T
    
    static func build(_ quantity: UInt, buildClosure: BuilderClosureN?) -> [T]
    func build(_ quantity: UInt, buildClosure: BuilderClosureN?) -> [T]
    
    func finish() -> T
}

extension Builder {
    
    static func build(buildClosure: BuilderClosure? = nil) -> T {
        return Self().build(buildClosure: buildClosure)
    }
    func build(buildClosure: BuilderClosure? = nil) -> T {
        buildClosure?(self)
        return finish()
    }
    
    static func build(_ quantity: UInt, buildClosure: BuilderClosureN? = nil) -> [T] {
        return Self().build(quantity, buildClosure: buildClosure)
    }
    
    func build(_ quantity: UInt, buildClosure: BuilderClosureN? = nil) -> [T] {
        let range = (0 as UInt...quantity)
        return range.map { (i: UInt) -> T in
            buildClosure?(self, i)
            return finish()
        }
    }
}

final class UserBuilder: Builder {
    
    typealias T = User
    
    func uniqueUsername() {
        self.username = UUID().uuidString
    }

    var username: String = "anyUsername"
    var password: String = "anyPassword"

    func finish() -> User {
        let user = User(name: username, password: password)
        
        return user
    }
}

final class TeamBuilder: Builder {
    
    typealias T = Team
    
    var name: String = "anyName"
    
    func finish() -> Team {
        return Team(name: name)
    }
}

final class TeamMembershipBuilder: Builder {
    
    typealias T = TeamMembership?
    
    var userid: Identifier?
    var teamid: Identifier?
    
    func finish() -> TeamMembership? {
        if let userid = userid, let teamid = teamid {
            return TeamMembership(teamid: teamid, userid: userid)
        }
        
        return nil
    }
}

final class RoleBuilder: Builder {
    
    typealias T = Role
    
    var name: String = "anyName"
    var readableName: String = "anyReadableName"
    
    func finish() -> Role {
        return Role(name: name, readableName: readableName)
    }
}

final class RoleAssignmentBuilder: Builder {
    
    typealias T = RoleAssignment?
    
    var userid: Identifier?
    var roleid: Identifier?
    
    func finish() -> RoleAssignment? {
        if let userid = userid, let roleid = roleid {
            return RoleAssignment(roleid: roleid, userid: userid)
        }
        
        return nil
    }
}
