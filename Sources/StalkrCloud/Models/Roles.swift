//
//  Roles.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 18/7/17.
//
//

import Vapor
import Foundation

protocol Roles: OptionSet {
    typealias RawValue = UInt
    var rawValue: UInt { get set }
    init(index: UInt)
}

extension Roles {
    init(index: UInt) {
        self.init()
        self.rawValue = 1 << index
    }
}

protocol RolesAssignable {
    associatedtype RolesType: Roles
    
    var roles: RolesType { get set }
    
    mutating func assignRoles(_ roles: RolesType)
    mutating func revokeRoles(_ roles: RolesType)
    func hasRoles(_ roles: RolesType) -> Bool
}

extension RolesAssignable {
    public mutating func assignRoles(_ roles: RolesType) {
        self.roles.rawValue |= roles.rawValue
    }
    
    public mutating func revokeRoles(_ roles: RolesType) {
        self.roles.rawValue &= ~roles.rawValue
    }
    
    public func hasRoles(_ roles: RolesType) -> Bool {
        return roles.isSubset(of: self.roles)
    }
}
