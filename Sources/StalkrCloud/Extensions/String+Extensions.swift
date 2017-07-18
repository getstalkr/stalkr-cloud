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

struct RandomStringOptions: OptionSet {
    var rawValue: Set<Character>
    
    static let lowercase = RandomStringOptions.string("abcdefghijklmnopqrstuvwxyz")
    static let uppercase = RandomStringOptions.string("ABCDEFGHIJKLMONPQRSTUVWXYZ")
    static let numbers = RandomStringOptions.string("0123456789")
    
    static func string(_ string: String) -> RandomStringOptions {
        return RandomStringOptions(rawValue: Set<Character>(string.characters))
    }
    
    init(rawValue: Set<Character>) {
        self.rawValue = rawValue
    }
    
    init() {
        self.rawValue = Set<Character>()
    }
    
    mutating func formUnion(_ other: RandomStringOptions) {
        self.rawValue.formUnion(other.rawValue)
    }
    
    mutating func formIntersection(_ other: RandomStringOptions) {
        self.rawValue.formIntersection(other.rawValue)
    }
    
    mutating func formSymmetricDifference(_ other: RandomStringOptions) {
        self.rawValue.formSymmetricDifference(other.rawValue)
    }
}

extension String {
    static func random(length: Int, options: RandomStringOptions) -> String {
        var randomString = ""
        let letters = options.rawValue
        
        for _ in 1...length {
            let randomIndex  = Int(arc4random_uniform(UInt32(letters.count)))
            let a = letters.index(letters.startIndex, offsetBy: randomIndex)
            randomString +=  String(letters[a])
        }
        
        return randomString
    }
}
