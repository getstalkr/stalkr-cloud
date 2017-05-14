//
//  Droplet+Shared.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/13/17.
//
//

import Foundation
import Vapor

extension Droplet {
    static let test: Droplet = {
        do {
            let config = try Config()
            try config.setup()
            
            let drop = try Droplet(config)
            
            return drop
        } catch {
            fatalError("could not instantiate shared drop")
        }
    }()
}
