//
//  SubjectBuilder.swift
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
    
    associatedtype T: Model
    
    typealias BuilderClosure = (Self) -> ()
    
    init(buildClosure: BuilderClosure)
    
    func build() -> T
}

class UserBuilder: Builder

    typealias T = User

    var username: String = "anyUsername"
    var password: String = "anyPassword"

    required init(buildClosure: (UserBuilder) -> ()) {
        
    }
    
    func build() -> User {
        
    }
}

class SubjectBuilder {
    
}
