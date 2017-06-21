//
//  Config+Setup.swift
//  stalkr-cloud
//
//  Created by Matheus Martins on 5/12/17.
//
//

import AuthProvider
import FluentProvider

public extension Config {
    public func setup() throws {
        Node.fuzzy = [Row.self, JSON.self, Node.self]
        
        try setupProviders()
    }
    
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(StalkrCloud.Provider.self)
    }
}
