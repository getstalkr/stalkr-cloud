//
//  Builder.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/12/17.
//
//

import XCTest

@testable import StalkrCloud

import Vapor
import Foundation
import FluentProvider

protocol Builder {
    
    associatedtype T
    
    typealias BuilderClosure = (Self) -> ()
    
    init()
    
    func build(buildClosure: BuilderClosure?) -> T
    
    func finish() -> T
}

extension Builder {
    func build(buildClosure: BuilderClosure? = nil) -> T {
        buildClosure?(self)
        return finish()
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

final class RoleBuilder: Builder {
    
    typealias T = Role
    
    var name: String = "anyName"
    var readableName: String = "anyReadableName"
    
    func finish() -> Role {
        return Role(name: name, readableName: readableName)
    }
}
