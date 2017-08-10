//
//  Provider.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/10/17.
//
//
import Foundation
import Vapor
import Fluent

public class Provider: Vapor.Provider {
    /// Called before the Droplet begins serving
    /// which is @noreturn.
    public func beforeRun(_ drop: Droplet) throws { }

    /// Called after the provider has initialized
    /// in the `Config.addProvider` call.
    public func boot(_ config: Config) throws {
        config.preparations.append(User.self)
        config.preparations.append(UserToken.self)
        config.preparations.append(Team.self)
        config.preparations.append(TeamMembership.self)
    }

    /// This should be the name of the actual repository
    /// that contains the Provider.
    ///
    /// this will be used for things like providing
    /// resources
    ///
    /// this will default to stripped camel casing,
    /// for example MyProvider will become `my-provider`
    /// if your Provider is providing resources
    /// it is HIGHLY recommended to provide a static let
    /// for performance considerations
    public static let repositoryName: String = "stalkr-cloud"

    required public init(config: Config) throws {
        print([1, 2].reduce("") { r, i in return r + i.description })
        [1, 2].dropFirst()
    }

    public func boot(_ drop: Droplet) throws {
        try setup(drop)
    }


    func setup(_ drop: Droplet) throws {
        // Preparations
        if let _ = drop.database {
            let admin = User(name: "admin", password: try "123456".hashed(by: drop))
            admin.roles = [.user, .admin]
            try admin.save()

            let test = User(name: "test", password: try "123456".hashed(by: drop))
            test.roles = [.user]
            test.shortToken = ShortToken(secret: "123456", expiration: Date.distantFuture)
            try test.save()
        }

        // Init Controllers
        let userController = UserController(drop: drop)
        let teamController = TeamController(drop: drop)

        let teamMembershipController = TeamMembershipController(drop: drop)

        // Add Routes
        userController.addRoutes()
        teamController.addRoutes()
        
        teamMembershipController.addRoutes()
    }
}
