//
//  Droplet+Shared.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/13/17.
//
//

import Foundation
@testable import Vapor

extension Droplet {
    static let test: Droplet = {
        do {
            let config = try Config()
            try config.setup()
            
            return try Droplet(config)
        } catch {
            fatalError("could not instantiate shared drop")
        }
    }()
}
