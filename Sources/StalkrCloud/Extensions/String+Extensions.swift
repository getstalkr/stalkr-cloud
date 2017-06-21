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

extension String {
    static func random(length: Int) -> String {
        
        var randomString = ""
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        for _ in 1...length {
            let randomIndex  = Int(arc4random_uniform(UInt32(letters.characters.count)))
            let a = letters.index(letters.startIndex, offsetBy: randomIndex)
            randomString +=  String(letters[a])
        }
        
        return randomString
    }
}
