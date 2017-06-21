//
//  String+Hashed.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 6/20/17.
//
//

import Foundation
import Vapor

extension String {
    func hashed(by drop: Droplet) throws -> String {
        return try drop.hash.make(self.makeBytes()).makeString()
    }
}
