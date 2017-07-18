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
    
    var userId: Identifier?
    var teamId: Identifier?
    
    func finish() -> TeamMembership? {
        if let teamId = teamId, let userId = userId {
            return TeamMembership(teamId: teamId, userId: userId)
        }
        
        return nil
    }
}
